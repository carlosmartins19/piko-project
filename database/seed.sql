INSERT INTO clients (name, email, phone, created_at) VALUES
                                                         ('Carlos Martins', 'carlos@example.com', '+351910000001', NOW() - INTERVAL '90 days'),
                                                         ('Ana Costa', 'ana.costa@example.com', '+351910000002', NOW() - INTERVAL '80 days'),
                                                         ('Miguel Silva', 'miguel.silva@example.com', '+351910000003', NOW() - INTERVAL '70 days'),
                                                         ('Beatriz Ferreira', 'beatriz.ferreira@example.com', '+351910000004', NOW() - INTERVAL '60 days'),
                                                         ('João Pereira', 'joao.pereira@example.com', '+351910000005', NOW() - INTERVAL '50 days');

INSERT INTO trainers (name, specialty) VALUES
                                           ('Inês Almeida', 'Strength Training'),
                                           ('Ricardo Lopes', 'Mobility'),
                                           ('Sofia Martins', 'HIIT'),
                                           ('Pedro Gomes', 'Personal Training');

INSERT INTO classes (title, trainer_id, starts_at, duration_minutes, capacity) VALUES
                                                                                   ('Strength Fundamentals', 1, NOW() - INTERVAL '20 days', 60, 6),
                                                                                   ('Morning Mobility', 2, NOW() - INTERVAL '15 days', 45, 8),
                                                                                   ('HIIT Express', 3, NOW() - INTERVAL '10 days', 30, 10),
                                                                                   ('Upper Body Strength', 1, NOW() - INTERVAL '5 days', 60, 6),
                                                                                   ('Full Body Personal Training', 4, NOW() + INTERVAL '2 days', 60, 4),
                                                                                   ('Mobility Reset', 2, NOW() + INTERVAL '4 days', 45, 8),
                                                                                   ('HIIT Advanced', 3, NOW() + INTERVAL '7 days', 30, 10),
                                                                                   ('Lower Body Strength', 1, NOW() + INTERVAL '10 days', 60, 6);

INSERT INTO bookings (client_id, class_id, status, created_at) VALUES
                                                                   (1, 1, 'attended', NOW() - INTERVAL '25 days'),
                                                                   (1, 2, 'attended', NOW() - INTERVAL '18 days'),
                                                                   (1, 3, 'cancelled', NOW() - INTERVAL '12 days'),
                                                                   (1, 4, 'attended', NOW() - INTERVAL '7 days'),
                                                                   (1, 5, 'confirmed', NOW() - INTERVAL '1 day'),

                                                                   (2, 1, 'attended', NOW() - INTERVAL '25 days'),
                                                                   (2, 3, 'no_show', NOW() - INTERVAL '11 days'),
                                                                   (2, 6, 'confirmed', NOW() - INTERVAL '2 days'),

                                                                   (3, 2, 'attended', NOW() - INTERVAL '16 days'),
                                                                   (3, 5, 'confirmed', NOW() - INTERVAL '1 day'),
                                                                   (3, 7, 'confirmed', NOW()),

                                                                   (4, 4, 'attended', NOW() - INTERVAL '6 days'),
                                                                   (4, 8, 'confirmed', NOW()),

                                                                   (5, 5, 'confirmed', NOW()),
                                                                   (5, 6, 'confirmed', NOW());

INSERT INTO payments (booking_id, amount, status, paid_at) VALUES
                                                               (1, 25.00, 'paid', NOW() - INTERVAL '24 days'),
                                                               (2, 20.00, 'paid', NOW() - INTERVAL '17 days'),
                                                               (3, 20.00, 'refunded', NOW() - INTERVAL '11 days'),
                                                               (4, 25.00, 'paid', NOW() - INTERVAL '6 days'),
                                                               (5, 30.00, 'pending', NULL),

                                                               (6, 25.00, 'paid', NOW() - INTERVAL '24 days'),
                                                               (7, 20.00, 'failed', NULL),
                                                               (8, 20.00, 'pending', NULL),

                                                               (9, 20.00, 'paid', NOW() - INTERVAL '15 days'),
                                                               (10, 30.00, 'paid', NOW() - INTERVAL '1 day'),
                                                               (11, 20.00, 'pending', NULL),

                                                               (12, 25.00, 'paid', NOW() - INTERVAL '5 days'),
                                                               (13, 25.00, 'pending', NULL),

                                                               (14, 30.00, 'pending', NULL),
                                                               (15, 20.00, 'pending', NULL);