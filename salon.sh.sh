#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {

if [[ $1 ]]

then

  echo -e "\n$1"
  
fi

SERVICES=$($PSQL "select service_id, name from services")

echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_TYPE

do

  echo "$SERVICE_ID) $SERVICE_TYPE"

done

read SERVICE_ID_SELECTED

HAVE_SERVICE=$($PSQL "select service_id from services where $SERVICE_ID_SELECTED = service_id")

if [[ -z $HAVE_SERVICE ]]

then

  MAIN_MENU "I could not find that service. What would you like today?"

else

  echo -e "\nWhat's your phone number?"

  read CUSTOMER_PHONE


  CUSTOMER_NAME=$($PSQL "select name from customers where '$CUSTOMER_PHONE' = phone")

  if [[ -z $CUSTOMER_NAME ]]

  then

    echo -e "\nI don't have a record for that phone number, what's your name?"

    read CUSTOMER_NAME

    INSERT_CUSTOMER=$($PSQL "insert into customers (name, phone) values ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

    SERVICE_NAME=$($PSQL "select name from services where $SERVICE_ID_SELECTED = service_id")

    echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
  
    read SERVICE_TIME

    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")

    INSERT_APPOINTMENT=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    # APPOINTMENT_INCLUSION=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $CUSTOMER_NAME."

  else

    SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")

    echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?" 

    read SERVICE_TIME

    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")

    INSERT_APPOINTMENT=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    # APPOINTMENT_INCLUSION=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $CUSTOMER_NAME."

  fi
fi

}

MAIN_MENU