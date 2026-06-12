DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS classes;
DROP TABLE IF EXISTS trainers;
DROP TABLE IF EXISTS clients;

CREATE TABLE clients (
                         id SERIAL PRIMARY KEY,
                         name VARCHAR(100) NOT NULL,
                         email VARCHAR(150) UNIQUE NOT NULL,
                         phone VARCHAR(30),
                         created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE trainers (
                          id SERIAL PRIMARY KEY,
                          name VARCHAR(100) NOT NULL,
                          specialty VARCHAR(100),
                          created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE classes (
                         id SERIAL PRIMARY KEY,
                         title VARCHAR(100) NOT NULL,
                         trainer_id INTEGER NOT NULL REFERENCES trainers(id),
                         starts_at TIMESTAMP NOT NULL,
                         duration_minutes INTEGER NOT NULL,
                         capacity INTEGER NOT NULL,
                         created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE bookings (
                          id SERIAL PRIMARY KEY,
                          client_id INTEGER NOT NULL REFERENCES clients(id),
                          class_id INTEGER NOT NULL REFERENCES classes(id),
                          status VARCHAR(30) NOT NULL CHECK (
                              status IN ('confirmed', 'cancelled', 'attended', 'no_show')
                              ),
                          created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE payments (
                          id SERIAL PRIMARY KEY,
                          booking_id INTEGER NOT NULL REFERENCES bookings(id),
                          amount NUMERIC(10,2) NOT NULL,
                          status VARCHAR(30) NOT NULL CHECK (
                              status IN ('paid', 'pending', 'failed', 'refunded')
                              ),
                          paid_at TIMESTAMP
);