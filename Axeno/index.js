const express = require('express');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');
const mysql = require('mysql2');


const app = express();


app.use(bodyParser.json());


const db = mysql.createConnection({
    host: 'localhost',
    user: 'root', // Your MySQL username
    password: '-', // Your MySQL root password
    database: 'user_management'
});


db.connect((err) => {
    if (err) {
        console.error('Could not connect to MySQL:', err);
        return;
    }
    console.log('Connected to MySQL');
});


app.post('/check-email', (req, res) => {
    const { email } = req.body;

    console.log("Received email:", email);

    if (!email) {
        return res.status(400).json({ message: 'Email is required' });
    }


    db.query('SELECT * FROM users WHERE email = ?', [email], (err, results) => {
        if (err) {
            console.error('Error checking existing email:', err);
            return res.status(500).json({ message: 'Server error' });
        }

        console.log("Email query result:", results);

 
        if (results.length > 0) {
            return res.status(400).json({ message: 'Email already exists' });
        }

  
        return res.status(200).json({ message: 'Email is available' });
    });
});


app.post('/signup', async (req, res) => {
    try {
        const { name, email, password } = req.body;

        if (!name || !email || !password) {
            return res.status(400).json({ message: 'Please provide name, email, and password' });
        }


        bcrypt.genSalt(10, (err, salt) => {
            if (err) throw err;


            bcrypt.hash(password, salt, (err, hashedPassword) => {
                if (err) throw err;

        
                db.query('INSERT INTO users (name, email, salt, hashed_password) VALUES (?, ?, ?, ?)',
                [name, email, salt, hashedPassword], (error, results) => {
                    if (error) {
                        console.error('Error inserting user data:', error);
                        return res.status(500).json({ message: 'Server error' });
                    }
                    res.status(200).json({ message: 'User created successfully' });
                });
            });
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error' });
    }
});


app.post('/login', async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ message: 'Please provide email and password' });
    }

 
    db.query('SELECT * FROM users WHERE email = ?', [email], (err, results) => {
        if (err) {
            console.error('Error checking email:', err);
            return res.status(500).json({ message: 'Server error' });
        }


        if (results.length === 0) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }


        const user = results[0];
        const { salt, hashed_password } = user;

        bcrypt.hash(password, salt, (err, hashedInputPassword) => {
            if (err) throw err;


            if (hashedInputPassword === hashed_password) {
                return res.status(200).json({ message: 'Login successful', id: user.id });
            } else {
                return res.status(401).json({ message: 'Invalid email or password' });
            }
        });
    });
});


app.post('/api/passwords', (req, res) => {
    const { userId, website, email, password } = req.body;

    if (!userId || !website || !email || !password) {
        return res.status(400).json({ message: 'All fields are required' });
    }


    bcrypt.hash(password, 10, (err, hashedPassword) => {
        if (err) {
            console.error('Error hashing password:', err);
            return res.status(500).json({ message: 'Server error' });
        }

   
        const query = 'INSERT INTO passwords (userId, website, email, password) VALUES (?, ?, ?, ?)';
        db.query(query, [userId, website, email, hashedPassword], (error, results) => {
            if (error) {
                console.error('Error inserting password data:', error);
                return res.status(500).json({ message: 'Failed to save password' });
            }
            return res.status(201).json({ message: 'Password saved successfully!' });
        });
    });
});


app.get('/api/passwords/:userId', (req, res) => {
    const userId = req.params.userId;


    db.query('SELECT id, website, email FROM passwords WHERE userId = ?', [userId], (err, results) => {
        if (err) {
            console.error('Error fetching passwords:', err);
            return res.status(500).json({ message: 'Server error' });
        }

        res.status(200).json(results); 
    });
});

app.post('/change-password', async (req, res) => {
    const { userId, currentPassword, newPassword } = req.body;

    if (!userId || !currentPassword || !newPassword) {
        return res.status(400).json({ message: 'All fields are required' });
    }


    db.query('SELECT salt, hashed_password FROM users WHERE id = ?', [userId], (err, results) => {
        if (err) {
            console.error('Error fetching user:', err);
            return res.status(500).json({ message: 'Server error' });
        }


        if (results.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        const user = results[0];
        const { salt, hashed_password } = user;


        bcrypt.hash(currentPassword, salt, (err, hashedInputPassword) => {
            if (err) throw err;

    
            if (hashedInputPassword === hashed_password) {
            
                bcrypt.genSalt(10, (err, newSalt) => {
                    if (err) throw err;

                    bcrypt.hash(newPassword, newSalt, (err, newHashedPassword) => {
                        if (err) throw err;

                
                        db.query('UPDATE users SET salt = ?, hashed_password = ? WHERE id = ?', [newSalt, newHashedPassword, userId], (error) => {
                            if (error) {
                                console.error('Error updating password:', error);
                                return res.status(500).json({ message: 'Server error' });
                            }
                            return res.status(200).json({ message: 'Password changed successfully!' });
                        });
                    });
                });
            } else {
                return res.status(401).json({ message: 'Current password is incorrect' });
            }
        });
    });
});


app.delete('/delete-account', (req, res) => {
    const { userId } = req.body;

    if (!userId) {
        return res.status(400).json({ message: 'User ID is required' });
    }

    db.query('DELETE FROM users WHERE id = ?', [userId], (err, results) => {
        if (err) {
            console.error('Error deleting account:', err);
            return res.status(500).json({ message: 'Server error' });
        }

        if (results.affectedRows === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        res.status(200).json({ message: 'Account deleted successfully' });
    });
});


app.get('/user-details', (req, res) => {
    const userId = req.query.userId;

    if (!userId) {
        return res.status(400).json({ message: 'User ID is required' });
    }

    db.query('SELECT name, email FROM users WHERE id = ?', [userId], (err, results) => {
        if (err) {
            console.error('Error fetching user details:', err);
            return res.status(500).json({ message: 'Server error' });
        }

        if (results.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        const user = results[0];
        res.status(200).json({ name: user.name, email: user.email });
    });
});

app.put('/update-email', (req, res) => {
    const { userId, newEmail } = req.body;

    if (!userId || !newEmail) {
        return res.status(400).json({ message: 'User ID and new email are required.' });
    }


    db.query('SELECT * FROM users WHERE email = ?', [newEmail], (err, results) => {
        if (err) {
            console.error('Error checking for existing email:', err);
            return res.status(500).json({ message: 'Server error.' });
        }

        if (results.length > 0) {
            return res.status(400).json({ message: 'The email is already in use by another account. Please choose a different one.' });
        }

     
        db.query('UPDATE users SET email = ? WHERE id = ?', [newEmail, userId], (err, result) => {
            if (err) {
                console.error('Error updating email:', err);
                return res.status(500).json({ message: 'Failed to update email.' });
            }

            res.status(200).json({ message: 'Email updated successfully.' });
        });
    });
});


app.put('/change-name', (req, res) => {
    const { userId, newName } = req.body;

    if (!userId || !newName) {
        return res.status(400).json({ message: 'User ID and new name are required.' });
    }

  
    db.query('SELECT * FROM users WHERE name = ?', [newName], (err, results) => {
        if (err) {
            console.error('Error checking for existing name:', err);
            return res.status(500).json({ message: 'Server error.' });
        }

        if (results.length > 0) {
            return res.status(400).json({ message: 'The name is already in use by another account. Please choose a different one.' });
        }


        db.query('UPDATE users SET name = ? WHERE id = ?', [newName, userId], (err, result) => {
            if (err) {
                console.error('Error updating name:', err);
                return res.status(500).json({ message: 'Failed to update name.' });
            }

            res.status(200).json({ message: 'Name updated successfully.' });
        });
    });
});


const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
