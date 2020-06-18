#!/bin/bash
 
  DATABASE="country"
  
  PSQL_CONNECT="postgres"
 
  TABLE_NAME_EXAMPLE="country"
    
  TABLE_NAME_PRESIDENT="president"

  LOG="$1" # $1 = DISPLAY ( to enable logs )
  
  # The USER which is used by Jaxy
  DB_USER_CONNECTION="admin"
  DB_PASSWORD_CONNECTION="admin"
 
  #################################################
  ### PROCESSOR ###################################
  #################################################
  
  tput setaf 2
  echo 
  echo -e " ####################################################  "
  echo -e " ################ Create DataBase ###################  "
  echo -e " ----------------------------------------------------  "
  echo -e " \e[90m$0        \e[32m                                "
  echo 
  echo -e " ##  DATABASE    : $DATABASE                           "
  echo -e " ##  TABLE_NAME  : $TABLE_NAME_EXAMPLE                 "
  echo
  echo -e " ####################################################  "
  echo 
  
  sleep 0.5
  
  tput setaf 7

  if which psql > /dev/null ; then
     echo " postgres command OK ..   "  
  else     
     echo " postgres command NOT FOUND  "
     echo " Script will abort           "
     exit 
  fi
  
  echo 
  
  if [ "$LOG" == "display" -o "$LOG" == "DISPLAY" ] ; then 
     LOG=""
  else 
     LOG=' 2> /dev/null '
  fi
   
  COMMAND=" sudo -u $PSQL_CONNECT psql $LOG "

  eval $COMMAND  << EOF
  
  DROP  DATABASE $DATABASE ;
  DROP  USER     $DB_USER_CONNECTION  ;
 
  CREATE DATABASE $DATABASE TEMPLATE template0 ; 
  CREATE USER $DB_USER_CONNECTION WITH PASSWORD '$DB_PASSWORD_CONNECTION'  ;
  
  \connect $DATABASE ;  
  
    
  CREATE TABLE $TABLE_NAME_EXAMPLE ( id               integer      , 
                                     name             varchar(255) ,
                                     capital          varchar(255) ,
                                     population       integer      , 
                                     year             integer      , 
                                     CONSTRAINT pk_country PRIMARY KEY ( id )
  ) ;
  
  -- Source http://avions.findthebest.fr
  
  INSERT INTO $TABLE_NAME_EXAMPLE VALUES ( 1 , 'Fance'  , 'Paris' ,  66991000 , 2017 ) ;
  INSERT INTO $TABLE_NAME_EXAMPLE VALUES ( 2 , 'Italie' , 'Rome'  ,  60800000 , 2015 ) ;
  
  GRANT SELECT ON $TABLE_NAME_EXAMPLE to $DB_USER_CONNECTION ;  
 
 
  -- Presicent 
  
  
  CREATE TABLE $TABLE_NAME_PRESIDENT  ( id               integer      ,
                                        first_name       varchar(255) ,
                                        last_name        varchar(255) ,
                                        country_id       integer      , 
                                        CONSTRAINT pk_president PRIMARY KEY ( first_name, last_name ),
                                        CONSTRAINT fk_president_country FOREIGN KEY (country_id ) 
                                                                        REFERENCES $TABLE_NAME_EXAMPLE (id )
  ) ;
  
  INSERT INTO $TABLE_NAME_PRESIDENT VALUES ( 10 , 'Macron' , 'Emmanuel'    , 1 ) ;
  INSERT INTO $TABLE_NAME_PRESIDENT VALUES ( 11 , 'Hollande' , 'François'  , 1 ) ;
  
  INSERT INTO $TABLE_NAME_PRESIDENT VALUES ( 12 , 'Mattarella' , 'Sergio'     , 2 ) ;
  INSERT INTO $TABLE_NAME_PRESIDENT VALUES ( 13 , 'Giorgio'    , 'Napolitano' , 2 ) ;
  
  GRANT SELECT ON $TABLE_NAME_PRESIDENT to $DB_USER_CONNECTION ;  
    
   \q
   
EOF

echo
