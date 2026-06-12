from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware

from database import get_connection

app = FastAPI(title="Piko Studios API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def health_check():
    return {"message": "Piko Studios API is running"}


@app.get("/clients/{client_id}/bookings")
def get_client_bookings(
    client_id: int,
    status: str | None = Query(default=None),
):
    allowed_statuses = {"confirmed", "cancelled", "attended", "no_show"}

    if status and status not in allowed_statuses:
        raise HTTPException(status_code=400, detail="Invalid booking status")

    query = """
        SELECT
            b.id AS booking_id,
            b.status AS booking_status,
            b.created_at AS booking_created_at,
            c.id AS class_id,
            c.title AS class_title,
            c.starts_at,
            c.duration_minutes,
            t.name AS trainer_name,
            p.amount,
            p.status AS payment_status,
            p.paid_at
        FROM bookings b
        JOIN classes c ON c.id = b.class_id
        JOIN trainers t ON t.id = c.trainer_id
        LEFT JOIN payments p ON p.booking_id = b.id
        WHERE b.client_id = %s
    """

    params = [client_id]

    if status:
        query += " AND b.status = %s"
        params.append(status)

    query += " ORDER BY c.starts_at DESC"

    try:
        conn = get_connection()

        with conn:
            with conn.cursor() as cursor:
                cursor.execute(query, params)
                rows = cursor.fetchall()

        return [
            {
                "booking_id": row["booking_id"],
                "booking_status": row["booking_status"],
                "booking_created_at": row["booking_created_at"],
                "class": {
                    "id": row["class_id"],
                    "title": row["class_title"],
                    "starts_at": row["starts_at"],
                    "duration_minutes": row["duration_minutes"],
                    "trainer_name": row["trainer_name"],
                },
                "payment": {
                    "amount": float(row["amount"]) if row["amount"] is not None else None,
                    "status": row["payment_status"],
                    "paid_at": row["paid_at"],
                }
                if row["payment_status"] is not None
                else None,
            }
            for row in rows
        ]

    except Exception as error:
        raise HTTPException(
            status_code=500,
            detail=f"Error fetching bookings: {str(error)}",
        )


@app.get("/classes/available")
def get_available_classes():
    query = """
        SELECT
            c.id,
            c.title,
            c.starts_at,
            c.duration_minutes,
            c.capacity,
            t.name AS trainer_name,
            COUNT(b.id) AS booked_spots,
            c.capacity - COUNT(b.id) AS available_spots
        FROM classes c
        JOIN trainers t ON t.id = c.trainer_id
        LEFT JOIN bookings b
            ON b.class_id = c.id
            AND b.status = 'confirmed'
        WHERE c.starts_at > NOW()
        GROUP BY c.id, c.title, c.starts_at, c.duration_minutes, c.capacity, t.name
        HAVING c.capacity - COUNT(b.id) > 0
        ORDER BY c.starts_at ASC;
    """

    try:
        conn = get_connection()

        with conn:
            with conn.cursor() as cursor:
                cursor.execute(query)
                rows = cursor.fetchall()

        return [
            {
                "id": row["id"],
                "title": row["title"],
                "starts_at": row["starts_at"],
                "duration_minutes": row["duration_minutes"],
                "capacity": row["capacity"],
                "trainer_name": row["trainer_name"],
                "booked_spots": row["booked_spots"],
                "available_spots": row["available_spots"],
            }
            for row in rows
        ]

    except Exception as error:
        raise HTTPException(
            status_code=500,
            detail=f"Error fetching available classes: {str(error)}",
        )


@app.get("/clients/{client_id}/summary")
def get_client_summary(client_id: int):
    query = """
        SELECT
            cl.id AS client_id,
            cl.name,
            cl.email,
            COUNT(b.id) AS total_bookings,
            COUNT(CASE WHEN b.status = 'attended' THEN 1 END) AS attended_classes,
            COUNT(CASE WHEN b.status = 'cancelled' THEN 1 END) AS cancelled_classes,
            COUNT(CASE WHEN b.status = 'no_show' THEN 1 END) AS no_show_classes,
            COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) AS upcoming_classes,
            COALESCE(SUM(CASE WHEN p.status = 'paid' THEN p.amount ELSE 0 END), 0) AS total_paid,
            MAX(c.starts_at) AS last_class_date
        FROM clients cl
        LEFT JOIN bookings b ON b.client_id = cl.id
        LEFT JOIN classes c ON c.id = b.class_id
        LEFT JOIN payments p ON p.booking_id = b.id
        WHERE cl.id = %s
        GROUP BY cl.id, cl.name, cl.email;
    """

    try:
        conn = get_connection()

        with conn:
            with conn.cursor() as cursor:
                cursor.execute(query, [client_id])
                row = cursor.fetchone()

        if row is None:
            raise HTTPException(status_code=404, detail="Client not found")

        return {
            "client_id": row["client_id"],
            "name": row["name"],
            "email": row["email"],
            "total_bookings": row["total_bookings"],
            "attended_classes": row["attended_classes"],
            "cancelled_classes": row["cancelled_classes"],
            "no_show_classes": row["no_show_classes"],
            "upcoming_classes": row["upcoming_classes"],
            "total_paid": float(row["total_paid"]),
            "last_class_date": row["last_class_date"],
        }

    except HTTPException:
        raise

    except Exception as error:
        raise HTTPException(
            status_code=500,
            detail=f"Error fetching client summary: {str(error)}",
        )