#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -c"
echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"
#List all servises
SHOW_SERVICES(){
LIST_ALL_SERVICES=$($PSQL "select * from services")
echo "$LIST_ALL_SERVICES" | while read SERVICE_ID BAR NAME
do
  if [[ ! ($SERVICE_ID =~ 'service_id' || $SERVICE_ID =~ '--' || $SERVICE_ID =~ '(' )  ]]
  then
    echo "$SERVICE_ID) $NAME"
  fi
done
echo -e "\nPick a service"
read SERVICE_ID_SELECTED 
SELECT_SERVICE $SERVICE_ID_SELECTED
}

SELECT_SERVICE(){
SERVICE_ID_SELECTED=$($PSQL "select service_id from services where service_id = $1")
CLEAN_PICKED_SERVICE_ID=`echo $SERVICE_ID_SELECTED| sed -r 's/^service_id ------------ | \(.*$//g' | sed -r 's/\(0 rows\)//g'`

if [[ -z "$CLEAN_PICKED_SERVICE_ID" ]]
then
 SHOW_SERVICES
else
  echo -e "What's your phone number?"
  read CUSTOMER_PHONE
  CHECK_CUSTOMER_ACCOUNT=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
  CLEAN_CHECK_CUSTOMER_ACCOUNT=`echo $CHECK_CUSTOMER_ACCOUNT | sed -r 's/customer_id ------------- | \(.*$//g' | sed -r 's/\(0 rows\)//g'`
  if [[ -z $CLEAN_CHECK_CUSTOMER_ACCOUNT ]]
  then
   echo -e "\nI don't have a record for that phone number, what's your name?"
   read CUSTOMER_NAME
   SERVICE_NAME_SELECTED=$($PSQL "select name from services where service_id = $1")
    SELECTED_SERVICE_NAME=`echo $SERVICE_NAME_SELECTED| sed -r 's/^name ------- | \(.*$//g' | sed -r 's/\(0 rows\)//g'`
   echo -e "\nWhat time would you like your $SELECTED_SERVICE_NAME, $CUSTOMER_NAME?"
   read SERVICE_TIME
   #create account
   NEW_CUSTOMER=$($PSQL "insert into customers(name,phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
   #get new customer id
   NEW_CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
   CLEAN_NEW_CUSTOMER_ID=`echo $NEW_CUSTOMER_ID | sed -r 's/customer_id ------------- | \(.*$//g' | sed -r 's/\(0 rows\)//g'`
   #and then create appointment
   CREATE_APPOINTMENT=$($PSQL "insert into appointments(customer_id,service_id,time) values($CLEAN_NEW_CUSTOMER_ID,$1,'$SERVICE_TIME')")
   if [[ $CREATE_APPOINTMENT =~ 'INSERT 0 1'  ]]
   then
    echo I have put you down for a $SELECTED_SERVICE_NAME at "$SERVICE_TIME", "$CUSTOMER_NAME".
   fi
  else
    #create only appointment
    CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
    CLEAN_CUSTOMER_NAME=`echo $CUSTOMER_NAME | sed -r 's/^name ------- | \(.*$//g' | sed -r 's/\(0 rows\)//g'`
    SERVICE_NAME_SELECTED=$($PSQL "select name from services where service_id = $1")
    SELECTED_SERVICE_NAME=`echo $SERVICE_NAME_SELECTED| sed -r 's/^name ------ | \(.*$//g' | sed -r 's/\(0 rows\)//g'`
    echo -e "\nWhat time would you like your $SELECTED_SERVICE_NAME, $CLEAN_CUSTOMER_NAME?"
     CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
   CLEAN_CUSTOMER_ID=`echo $CUSTOMER_ID | sed -r 's/customer_id ------------- | \(.*$//g' | sed -r 's/\(0 rows\)//g'`
    read SERVICE_TIME
    CREATE_APPOINTMENT=$($PSQL "insert into appointments(customer_id,service_id,time) values($CLEAN_CUSTOMER_ID,$1,'$SERVICE_TIME')")
   if [[ $CREATE_APPOINTMENT =~ 'INSERT 0 1'  ]]
   then
    echo I have put you down for a $SELECTED_SERVICE_NAME at "$SERVICE_TIME", "$CLEAN_CUSTOMER_NAME".
   fi
  fi
fi
}



SHOW_SERVICES
