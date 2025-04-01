#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Display available services
echo -e "\nWelcome to the Salon! Choose a service:\n"
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
  echo "$SERVICE_ID) $SERVICE_NAME"
done

# Function to prompt user for service selection
GET_SERVICE() {
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z "$SERVICE_NAME" ]]; then
    echo -e "\nInvalid selection. Please choose a valid service:\n"
    echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done
    GET_SERVICE
  fi
}

# Get user input for service selection
GET_SERVICE

# Get user phone number
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

# If customer doesn't exist, ask for name and insert into customers table
if [[ -z "$CUSTOMER_NAME" ]]; then
  echo -e "\nEnter your name:"
  read CUSTOMER_NAME
  INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi

# Get customer ID
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Get appointment time
echo -e "\nEnter the appointment time:"
read SERVICE_TIME

# Insert appointment
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Confirm the appointment
SERVICE_NAME_FORMATTED=$(echo "$SERVICE_NAME" | sed 's/^ *//g')
echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
