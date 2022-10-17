#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~Salon~~~~~\n"

MAIN_MENU() {
  

  # check for argument in the function call
  # if the function was called with an argument, print it on screen
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Query all the services
  SERVICES_RESULT="$($PSQL "SELECT * FROM services")"
  # create an array that holds all valid service IDs
    #t todo: find a way to get the valid IDs through a query so its automated
  SERVICES=('1' '2' '3')

  # Show list of servvices
  echo "Pick a service"
  echo "$SERVICES_RESULT" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
      
    done
  

  # get service choice from customer
  read SERVICE_ID_SELECTED

    # test if the customer picked a valid service number
    if [[ " ${SERVICES[*]} " =~ " ${SERVICE_ID_SELECTED} " ]]
    then
       # a valid service number was picked
       # get the service name
      SERVICE_NAME="$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")"
      echo "Selected:$SERVICE_NAME"
      
      echo "Please input your phone number"
      # get the phone number
      read CUSTOMER_PHONE

      # check customer table for the phone number
      # if the number exists save customer name in variable
      CUSTOMER_NAME="$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE' ")"
      #if phone number doesn't exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        # ask for the customer's name
        echo "Please enter your name"
        read CUSTOMER_NAME
        # add new customer to customers table
        INSERT_CUSTOMER_RESULT="$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")"
      fi

      # ask for the time of the appointment
      echo "At what time do you want to have your appointment?"
      read SERVICE_TIME
        # Todo: Check the time slot for availability
      # get customer id
      CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")"
      # add appointment to the appointment table
      INSERT_APPOINTMENT_RESULT="$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")"
      # tell the customer about their appointment. (sed command to trim empty spaces)
      echo -e "I have put you down for a$SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    else
      # an invalid number was picked
      # redirect back to the start
      MAIN_MENU "Pick a valid number."
    fi
}


MAIN_MENU


