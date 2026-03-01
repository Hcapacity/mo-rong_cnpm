import os
import datetime
from celery import Celery
from sqlalchemy import create_engine, Column, Integer, String, DateTime
from sqlalchemy.orm import declarative_base, sessionmaker

# Architecture Initialization: Message Broker and Database Config
DATABASE_URI = os.getenv('PROD_DATABASE_URL', 'sqlite:///sers_local.db')
REDIS_BROKER = os.getenv('CELERY_BROKER_URL', 'redis://localhost:6379/0')

app_celery = Celery('sers_async_worker', broker=REDIS_BROKER)
app_celery.conf.timezone = 'UTC'

engine = create_engine(DATABASE_URI)
Base = declarative_base()
Session = sessionmaker(bind=engine)

# Model Layer: Data encapsulation mapping to the UML Class Diagram
class EventEntity(Base):
    __tablename__ = 'scheduled_events'
    id = Column(Integer, primary_key=True)
    title = Column(String(150), nullable=False)
    event_timestamp = Column(DateTime, nullable=False)
    target_email = Column(String(150), nullable=False)
    async_task_id = Column(String(100)) # Stores Celery ID for revocation

Base.metadata.create_all(engine)

# Asynchronous Worker Layer: Executed completely independent of the web server
@app_celery.task(name='notification.dispatch', bind=True)
def dispatch_reminder_alert(self, entity_id, target_email, event_title):
    """
    Background worker simulating external SMTP connection.
    This function blocks its own thread, but does not block the web server.
    """
    try:
        alert_payload = f"Automated Reminder: '{event_title}' is approaching."
        
        # System logging to verify successful delivery for administrative review
        log_entry = f"[{datetime.datetime.utcnow().isoformat()}] SUCCESS -> {target_email} | Payload: {alert_payload}\n"
        with open("system_delivery_logs.txt", "a") as file_handle:
            file_handle.write(log_entry)
            
        return {"execution_status": "success", "entity_id": entity_id}
    except Exception as runtime_error:
        return {"execution_status": "failed", "error_trace": str(runtime_error)}

# Controller Layer: Orchestrates Model updates and Broker dispatch
class SersController:
    def __init__(self):
        self.db_session = Session()

    def schedule_new_event(self, title, event_timestamp, target_email, offset_minutes):
        """
        Validates input, persists the Model, calculates temporal offsets,
        and pushes the payload to the Redis broker.
        """
        # Primary logical validation
        if not title or not target_email:
            raise ValueError("Data Validation Failure: Title and Email are mandatory parameters.")
            
        current_system_time = datetime.datetime.utcnow()
        if event_timestamp <= current_system_time:
            raise ValueError("Temporal Logic Failure: Scheduled events must occur in the future.")

        # 1. Persist the Model state
        new_event = EventEntity(
            title=title,
            event_timestamp=event_timestamp,
            target_email=target_email
        )
        self.db_session.add(new_event)
        self.db_session.commit()

        # 2. Calculate precise temporal trigger offset
        calculated_trigger = event_timestamp - datetime.timedelta(minutes=offset_minutes)
        if calculated_trigger < current_system_time:
            # Fallback mechanism if offset pushes trigger into the past
            calculated_trigger = current_system_time + datetime.timedelta(seconds=5)

        # 3. Dispatch the payload to the asynchronous broker
        dispatched_task = dispatch_reminder_alert.apply_async(
            args=[new_event.id, new_event.target_email, new_event.title],
            eta=calculated_trigger
        )

        # 4. Update Model with task identifier to allow future revocation
        new_event.async_task_id = dispatched_task.id
        self.db_session.commit()

        return new_event.id

    def revoke_existing_event(self, entity_id):
        """
        Removes the Model entity and aggressively terminates the pending asynchronous task.
        """
        target_event = self.db_session.query(EventEntity).filter_by(id=entity_id).first()
        if target_event:
            if target_event.async_task_id:
                # Intercept the message broker to prevent misfire of canceled events
                app_celery.control.revoke(target_event.async_task_id, terminate=True)
            self.db_session.delete(target_event)
            self.db_session.commit()
            return True
        return False