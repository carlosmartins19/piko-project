import {useEffect, useState} from 'react'
import './App.css'

const API_BASE_URL = "http://127.0.0.1:8000";


function App() {

  const [clientId, setClientId] = useState(1);
  const [status, setStatus] = useState("");
  const [bookings, setBookings] = useState([]);
  const [availableClasses, setAvailableClasses] = useState([]);
  const [summary, setSummary] = useState(null);
  const [loadingBookings, setLoadingBookings] = useState(false);
  const [loadingClasses, setLoadingClasses] = useState(false);
  const [loadingSummary, setLoadingSummary] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    fetchBookings();
    fetchSummary();
  }, [clientId, status]);

  useEffect(() => {
    fetchAvailableClasses();
  }, []);

  async function fetchBookings() {
    try {
      setLoadingBookings(true);
      setError("");

      const query = status ? `?status=${status}` : "";
      const response = await fetch(
          `${API_BASE_URL}/clients/${clientId}/bookings${query}`
      );

      if (!response.ok) {
        throw new Error("Failed to fetch bookings");
      }

      const data = await response.json();
      setBookings(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoadingBookings(false);
    }
  }

  async function fetchSummary() {
    try {
      setLoadingSummary(true);
      setError("");

      const response = await fetch(
          `${API_BASE_URL}/clients/${clientId}/summary`
      );

      if (!response.ok) {
        throw new Error("Failed to fetch client summary");
      }

      const data = await response.json();
      setSummary(data);
    } catch (err) {
      setError(err.message);
      setSummary(null);
    } finally {
      setLoadingSummary(false);
    }
  }

  async function fetchAvailableClasses() {
    try {
      setLoadingClasses(true);
      setError("");

      const response = await fetch(`${API_BASE_URL}/classes/available`);

      if (!response.ok) {
        throw new Error("Failed to fetch available classes");
      }

      const data = await response.json();
      setAvailableClasses(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoadingClasses(false);
    }
  }

  function formatDate(value) {
    if (!value) return "N/A";

    return new Date(value).toLocaleString("pt-PT", {
      dateStyle: "medium",
      timeStyle: "short",
    });
  }

  return (
      <main className="app">
        <header className="hero">
          <div>
            <p className="eyebrow">Piko Studios</p>
            <h1>Client Bookings Dashboard</h1>
            <p>
              Mini full-stack project with React, FastAPI and PostgreSQL.
            </p>
          </div>
        </header>

        <section className="controls card">
          <label>
            Client
            <select
                value={clientId}
                onChange={(event) => setClientId(Number(event.target.value))}
            >
              <option value={1}>Carlos Martins</option>
              <option value={2}>Ana Costa</option>
              <option value={3}>Miguel Silva</option>
              <option value={4}>Beatriz Ferreira</option>
              <option value={5}>João Pereira</option>
            </select>
          </label>

          <label>
            Booking status
            <select
                value={status}
                onChange={(event) => setStatus(event.target.value)}
            >
              <option value="">All</option>
              <option value="confirmed">Confirmed</option>
              <option value="attended">Attended</option>
              <option value="cancelled">Cancelled</option>
              <option value="no_show">No show</option>
            </select>
          </label>
        </section>

        {error && <p className="error">{error}</p>}

        <section className="summary-grid">
          <article className="card">
            <h2>Client summary</h2>

            {loadingSummary && <p>Loading summary...</p>}

            {!loadingSummary && summary && (
                <div className="stats">
                  <div>
                    <span>Total bookings</span>
                    <strong>{summary.total_bookings}</strong>
                  </div>
                  <div>
                    <span>Attended</span>
                    <strong>{summary.attended_classes}</strong>
                  </div>
                  <div>
                    <span>Cancelled</span>
                    <strong>{summary.cancelled_classes}</strong>
                  </div>
                  <div>
                    <span>No show</span>
                    <strong>{summary.no_show_classes}</strong>
                  </div>
                  <div>
                    <span>Upcoming</span>
                    <strong>{summary.upcoming_classes}</strong>
                  </div>
                  <div>
                    <span>Total paid</span>
                    <strong>€{summary.total_paid}</strong>
                  </div>
                </div>
            )}
          </article>

          <article className="card">
            <h2>Available classes</h2>

            {loadingClasses && <p>Loading classes...</p>}

            {!loadingClasses && (
                <ul className="compact-list">
                  {availableClasses.map((item) => (
                      <li key={item.id}>
                        <div>
                          <strong>{item.title}</strong>
                          <span>{item.trainer_name}</span>
                        </div>
                        <div>
                          <span>{formatDate(item.starts_at)}</span>
                          <strong>{item.available_spots} spots</strong>
                        </div>
                      </li>
                  ))}
                </ul>
            )}
          </article>
        </section>

        <section className="card">
          <h2>Bookings</h2>

          {loadingBookings && <p>Loading bookings...</p>}

          {!loadingBookings && bookings.length === 0 && (
              <p>No bookings found for this filter.</p>
          )}

          {!loadingBookings && bookings.length > 0 && (
              <div className="booking-list">
                {bookings.map((booking) => (
                    <article key={booking.booking_id} className="booking-card">
                      <div>
                        <h3>{booking.class.title}</h3>
                        <p>{booking.class.trainer_name}</p>
                        <p>{formatDate(booking.class.starts_at)}</p>
                      </div>

                      <div className="booking-meta">
                  <span className={`pill ${booking.booking_status}`}>
                    {booking.booking_status}
                  </span>

                        {booking.payment ? (
                            <span>
                      {booking.payment.status} · €{booking.payment.amount}
                    </span>
                        ) : (
                            <span>No payment</span>
                        )}
                      </div>
                    </article>
                ))}
              </div>
          )}
        </section>
      </main>
  );
}

export default App
