#!/bin/bash

    # $1 IP_HOST  
    # $2 NAME_SPACE  
    # $3 Read_Write_Port 
    # $4 Read_Only_Port
    # $5 WhichSI 
    # $6 DATAB_BASE { [postgresql] - mysql } 

    set -e
   
    SCRIPT_PATH="../scripts"
 
    GET_ABS_PATH() {
       # $1 : relative filename
       echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
    }

    EXIT() {
     if [ $PPID = 0 ] ; then exit ; fi
     parent_script=`ps -ocommand= -p $PPID | awk -F/ '{print $NF}' | awk '{print $1}'`
     if [ $parent_script = "bash" ] ; then
         echo; echo -e " \e[90m exited by : $0 \e[39m " ; echo
         exit 2
     else
         echo ; echo -e " \e[90m exited by : $0 \e[39m " ; echo
         kill -9 `ps --pid $$ -oppid=`;
         exit 2
     fi
    } 
    
    read_type_connection_properties()     {

        file="$1"
        
        while IFS="=" read -r key value; do
        
            key=$(echo $key | xargs) 
        
            value=$(echo $value | xargs)

            case "$key" in
            
              "type")           CONNECTION_TYPE="$value" 
              ;;
              "csv_directory")  DATARIV_CSV_DIRECTORY="$value" 
              ;;
              "csv_separator")  DATARIV_CSV_SEPARATOR="$value" 
              ;;
              "jdbc.url")       DATARIV_JDBC_URL="$value"
              ;;
              "jdbc.user")      DATARIV_JDBC_USER="$value"
              ;;                         
              "jdbc.password")  DATARIV_JDBC_PASSWORD="$value"
              ;;
            
            esac

        done < "$file"

    }
   
    CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cd $CURRENT_PATH

    ROOT_PATH="${CURRENT_PATH/}"
   
    WORK_TMP="work-tmp"   

    # If SI folder not found in the same place of the script  
    # Search in the parent folder
    if [ ! -d "$ROOT_PATH/SI/" ] ; then
        ROOT_PATH="${ROOT_PATH%/*}"
        WORK_TMP="../work-tmp"   
    fi   
    
    ##################################################
    ##  INSTALLATION  ################################
    ##################################################
    
    if [ "$#" -ne 2 -a "$1" == "-i" ] ; then 
         echo
         echo "  -> The arg [ -i ] is used only for installation. Cmd Ex : "$0" -i db=postgresql "
         EXIT
       
    elif [ "$#" -eq 2 -a "$1" == "-i" ] ; then 
    
        if [ "$2" != "db=postgresql" -a "$2" != "db=mysql" ] ;  then 
           echo
           echo "  -> Database must be : postgresql / mysql.  Cmd Ex : "$0" -i db=postgresql "
           EXIT
        fi
        
        s_db=$2 
        db="${s_db/db=/''}"
        
        $SCRIPT_PATH/00_install_libs.sh db=$db   
        
        EXIT 
    fi
    
    #####################################################
    #####################################################
    
    
    while [[ "$#" > "0" ]] ; do
    
     case $1 in
     
         (*=*) KEY=${1%%=*}
         
               VALUE=${1#*=}
               
               case "$KEY" in
               
                    ("ip")                      IP_HOST=$VALUE
                    ;;
                    ("rw")                      Read_Write_Port=$VALUE
                    ;;
                    ("ro")                      Read_Only_Port=$VALUE
                    ;;
                    ("si")                      WhichSI=$VALUE
                    ;;
                    ("db")                      DATABASE=$VALUE
                    ;;      
                    ("ext_obda")                EXTENSION_OBDA=$VALUE
                    ;;      
                    ("ext_graph")               EXTENSION_SPEC=$VALUE
                    ;;
                    ("class_file_name")         CLASS_FILE=$VALUE
                    ;; 
                    ("namespace")               NAME_SPACE=$VALUE
                    ;;
                    ("sparql_file_name")        SPARQL_FILE=$VALUE
                    ;;
                    ("csv_file_name")           CSV_FILE_NAME=$VALUE
                    ;; 
                    ("valide_csv_file_name")    VALIDE_CSV_FILE_NAME=$VALUE
                    ;; 
                    ("csv_sep")                 CSV_SEP=$VALUE
                    ;;  
                    ("intra_separators")        INTRA_SEPARATORS=$VALUE
                    ;; 
                    ("columns")                 COLUMNS_TO_VALIDATE=$VALUE
                    ;; 
                    ("connec_file_name")        CONNEC_FILE_NAME=$VALUE
                    
                    # Ontop ARGS
                    ;;
                    ("ontop_xms")               ONTOP_XMS=$VALUE
                    ;;
                    ("ontop_xmx")               ONTOP_XMX=$VALUE
                    ;; 
                    ("ontop_ttl_format")        ONTOP_TTL_FORMAT=$VALUE
                    ;;
                    ("ontop_batch")             ONTOP_BATCH=$VALUE
                    ;;
                    ("ontop_page_size")         ONTOP_PAGE_SIZE=$VALUE
                    ;;
                    ("ontop_flush_count")       ONTOP_FLUSH_COUNT=$VALUE
                    ;;
                    ("ontop_merge")             ONTOP_MERGE=$VALUE
                    ;;
                    ("ontop_query")             ONTOP_QUERY=$VALUE
                    ;; 
                    ("ontop_fragment")          ONTOP_FRAGMENT=$VALUE
                    ;;
                    ("ontop_log_level")         ONTOP_LOG_LEVEL=$VALUE 
                    ;;
                    ("yed_gen_ontop_version")   YED_GEN_ONTOP_VERSION=$VALUE
                    
                    # Corese ARGS
                    ;;
                    ("corese_xms")              CORESE_XMS=$VALUE
                    ;;
                    ("corese_xmx")              CORESE_XMX=$VALUE
                    ;;                
                    ("corese_query")            CORESE_QUERY=$VALUE
                    ;;
                    ("corese_peek")             CORESE_PEEK=$VALUE
                    ;;
                    ("corese_fragment")         CORESE_FRAGMENT=$VALUE
                    ;;
                    ("corese_format")           CORESE_FORMAT=$VALUE
                    ;;    
                    ("corese_flush_count")      CORESE_FLUSH_COUNT=$VALUE
                    ;;  
                    ("corese_output_extension") CORESE_OUTPUT_EXTENSION=$VALUE 
                    ;;
                    ("class_values")            CLASS_VALUES=$VALUE
                    ;;  
                    ("query_user")              QUERY=$VALUE
                    ;;  
                    ("strict_mode_filter")      STRICT_MODE_FILTER=$VALUE
                    ;;  
                    ("corese_extract_only_inference")   CORESE_EXCTRACT_ONLY_INFERENCE=$VALUE
                    ;;  
                    ("reserved_paramaters_words")       RESERVED_PARAMETERS_WORDS=$VALUE
                    ;;
                    ("output_root")                     OUTPUT_ROOT=$VALUE     
                    
                    # DataRiv ARGS 
                    ;;
                    ("datariv_page_size")               DATARIV_PAGE_SIZE=$VALUE
                    ;;
                    ("datariv_fragment")                DATARIV_FRAGMENT=$VALUE
                    ;;
                    ("datariv_flush_count")             DATARIV_FLUSH_COUNT=$VALUE
                    ;;
                    ("datariv_xms")                     DATARIV_XMS=$VALUE
                    ;;
                    ("datariv_xmx")                     DATARIV_XMX=$VALUE
                    ;;
                    ("datariv_log_level")               DATARIV_LOG_LEVEL=$VALUE
                    ;;
                    ("datariv_parallelism")             DATARIV_PARALLELISM=$VALUE
                    ;;
                    ("datariv_entailment_peek")         DATARIV_ENTAILMENT_PEEK=$VALUE
                    ;;
                    ("datariv_entailment_parallelism")  DATARIV_ENTAILMENT_PARALLELISM=$VALUE
                    ;;
                    ("datariv_my_sql_version")          DATARIV_MY_SQL_VERSION=$VALUE
                    ;;
                    ("datariv_entailment_engine_level") DATARIV_ENTAILMENT_ENGINE_LEVEL=$VALUE 
                    ;;
                    ("must_not_be_empty")               MUST_NOT_BE_EMPTY_NODES=$VALUE

               esac
               
         ;;
         ontop_debug )                            ONTOP_DEBUG="debug"
         ;;
         corese_ignore_line_break )               CORESE_IGNORE_LINE_BREAK="ignore_line_break"
         ;;
         ontop_debug )                            ONTOP_DEBUG="debug"
         ;;
         datariv_entailment )                     DATARIV_ENTAILMENT="e"
         ;;
         datariv_entailment_rm )                  DATARIV_ENTAILMENT_RM="e.rm"
         ;;
         datariv_entailment_rm_on_load )          DATARIV_ENTAILMENT_RM_ON_LOAD="e.rm_on_load"
         ;;   
         datariv_entailment_out_ontology )        DATARIV_ENTAILMENT_OUT_ONTOLOGY="e.out_ontology"
         ;;
         datariv_index_columns )                  DATARIV_INDEX_COLUMNS="index_columns"
         ;; 
         datariv_debug )                          DATARIV_DEBUG="debug"
         ;; 
         datariv_entailment_disable_cache_graph ) DATARIV_ENTAILMENT_DISABLE_CACHE_GRAH="e.disable_cache_graph" 
         ;;
         datariv_only_entailment)                 DATARIV_ONLY_ENTAILMENT="only_entailment"
         ;;
         
         help | -help | -h )  
              echo
              echo " Total Arguments : ***                                                                                "
              echo
              echo "   ip=                   :  IP_HOST ( or Hostname )                                                   "
              echo "   namespace=            :  NAME_SPACE                                                                "
              echo "   rw=                   :  Read_Write_Port                                                           "
              echo "   ro=                   :  Read_Only_Port                                                            "
              echo "   si=                   :  WhichSI  : DEFAULT { SI folder }                                          "
              echo "   db=                   :  DATA_BASE { [postgresql] - mysql }                                        "
              echo "   ext_obda=             :  Extension of obda files. Ex : ext_obda=obda                               "
              echo "   ext_graph=            :  Extension of specs graphs. Ex : ext_graph=graphml                         "
              echo "   class_file_name=      :  Class file name. Ex : class_file_name=class.txt                           "
              echo "   sparql_file_name=     :  Sparql file name. Ex : sparql_file_name=sparql.txt                        "
              echo "   csv_file_name=        :  Input semantic CSV. Ex : sparql_file_name=semantic_si.csv                 "
              echo "   valide_csv_file_name= :  Output valide CSV. Ex : valide_csv_file_name=pipeline_si.csv              "
              echo "   csv_sep=              :  CSV separator. Ex : csv_sep=';'                                           "
              echo "   intra_separators=     :  Intra CSV separators. Ex : intra_separators=' -intra_sep , -intra_sep < ' "
              echo "   columns=              :  Columns to validate using Ontology. Ex : columns=' -column 0 -column 1'   "
              echo "   ontop_xms=            :  xms Ontop                                                                 "
              echo "   ontop_xmx=            :  xmx Ontop                                                                 "
              echo "   ontop_ttl_format=     :   "
              echo "   ontop_batch=          :   "
              echo "   ontop_page_size=      :   "
              echo "   ontop_flush_count=    :   "
              echo "   ontop_merge=          :   "
              echo "   ontop_query=          :   "
              echo "   ontop_fragment=       :   "
              echo "   corese_xms=           :   "
              echo "   corese_xmx=           :   "
              echo "   corese_query=         :   "
              echo "   corese_peek=          :   "
              echo "   corese_fragment=      :   "
              echo "   corese_format=        :   "
              echo "   corese_flush_count=   :   "
              echo

              EXIT ;
        
     esac
     
     shift
     
    done    
   
    WhichSI=${WhichSI:-OLA}
    IP_HOST=${IP_HOST:-localhost}    
    Read_Write_Port=${Read_Write_Port:-7777}
    Read_Only_Port=${Read_Only_Port:-8888}
    DATABASE=${DATABASE:-postgresql}
    NAME_SPACE=${NAME_SPACE:-data}

    SI_FILE=${SI_FILE:-postgresql}
    NAME_SPACE=${NAME_SPACE:-data}
    
    #CLASS FILE 
    CLASS_FILE=${CLASS_FILE:-"class.txt"}
    #SPARQL FILE 
    SPARQL_FILE_NAME=${SPARQL_FILE_NAME:-"sparql.txt"}
    
    CLASS_VALUE=""
    DISCRIMINATOR_COLUMN=""

    ## EXTENSIONS
    EXTENSION_OBDA=${EXTENSION_OBDA:-"obda"}
    EXTENSION_SPEC=${EXTENSION_SPEC:-"graphml"}
     
    CSV_FILE_NAME=${CSV_FILE_NAME:-"semantic_si.csv"}
    VALIDE_CSV_FILE_NAME=${VALIDE_CSV_FILE_NAME:-"pipeline_si.csv"}

    CONNEC_FILE_NAME=${CONNEC_FILE_NAME:-"connection.txt"}
        
    ## CSV ARGS
    CSV_SEP=${CSV_SEP:-";"}
    INTRA_SEPARATORS=${INTRA_SEPARATORS:-" -intra_sep , "}
    COLUMNS_TO_VALIDATE=${COLUMNS_TO_VALIDATE:-" -column 0 -column 1 -column 2 -column 4 -column 6 -column 7 -column 8 -column 10 "}
            
    ##############
    ## yedGen   ##
    ##############
    
    YED_GEN_ONTOP_VERSION=${YED_GEN_ONTOP_VERSION:-"V4"}  
    
    #################
    ## Ontop ARGS  ##
    #################
    
    ONTOP_DEBUG=${ONTOP_DEBUG:-""}
    
    ONTOP_LOG_LEVEL=${ONTOP_LOG_LEVEL:-"OFF"}
    
    ONTOP_QUERY=${ONTOP_QUERY:-" SELECT ?S ?P ?O { ?S ?P ?O } "}
    # Output Format
    ONTOP_TTL_FORMAT=${ONTOP_TTL_FORMAT:-"ttl"} 
    # Batch disable by default 
    ONTOP_BATCH=${ONTOP_BATCH:-""} # enable : "batch"
    # LIMIT for SQL Queries 
    ONTOP_PAGE_SIZE=${ONTOP_PAGE_SIZE:-"200000"}
    # Number triples by file
    ONTOP_FRAGMENT=${ONTOP_FRAGMENT:-"1000000"}
    # Total triples in memory befobe wrinting in the file 
    ONTOP_FLUSH_COUNT=${ONTOP_FLUSH_COUNT:-"500000"}    
    # Merge : Extract Data from database ignoring Ontology 
    # ( by using empty Ontology )
    ONTOP_MERGE=${ONTOP_MERGE:-""} # enable : "merge"    
    # Memory 
    ONTOP_XMS=${ONTOP_XMS:-"8g"}
    ONTOP_XMX=${ONTOP_XMX:-"8g"}
   
    ##########################################
    ##########################################
 
    ##################
    ## Corese ARGS  ##
    ##################
    
    CORESE_IGNORE_LINE_BREAK=${CORESE_IGNORE_LINE_BREAK:-""}
    
    CORESE_QUERY=${CORESE_QUERY:-"SELECT ?S ?P ?O { ?S ?P ?O . filter( !isBlank(?S) ) . filter( !isBlank(?O) )  } "} 
    CORESE_PEEK=${CORESE_PEEK:-"-peek 6 "}
    # Size file = -f
    CORESE_FRAGMENT=${CORESE_FRAGMENT:-"-f 1000000 "}  
    # output Format ( default = ttl )
    CORESE_FORMAT=${CORESE_FORMAT:-"-F ttl "}
    # Write in the file on each flushCount
    CORESE_FLUSH_COUNT=${CORESE_FLUSH_COUNT:-"-flushCount 250000"}
    # Memory 
    CORESE_XMS=${CORESE_XMS:-"15g"}
    CORESE_XMX=${CORESE_XMX:-"15g"}
   
    ##########################################
    ##########################################
 
    ####################
    ## dataRiv        ##
    ####################

    DATARIV_PAGE_SIZE=${DATARIV_PAGE_SIZE:-"20000"}
    DATARIV_FRAGMENT=${DATARIV_FRAGMENT:-"0"}
    DATARIV_FLUSH_COUNT=${DATARIV_FLUSH_COUNT:-"20000"}
    DATARIV_XMS=${DATARIV_XMS:-"8g"}
    DATARIV_XMX=${DATARIV_XMX:-"8g"}
    DATARIV_LOG_LEVEL=${DATARIV_LOG_LEVEL:-"INFO"}
    DATARIV_DEBUG=${DATARIV_DEBUG:-""}
   
    DATARIV_PARALLELISM=${DATARIV_PARALLELISM:-"1"}
    
    DATARIV_ENTAILMENT=${DATARIV_ENTAILMENT:-""} # Enable Entailment !
    DATARIV_ENTAILMENT_PEEK=${DATARIV_ENTAILMENT_PEEK:-"1"}
    DATARIV_ENTAILMENT_PARALLELISM=${DATARIV_ENTAILMENT_PARALLELISM:-"0"}
    DATARIV_ENTAILMENT_RM=${DATARIV_ENTAILMENT_RM:-"e.rm"}
    
    DATARIV_MY_SQL_VERSION=${DATARIV_MY_SQL_VERSION:-"v8_0_17"}
    
    ##########################################
    ##########################################
    
    $SCRIPT_PATH/01_use_si.sh si=$WhichSI
     
    if [ -z "$WhichSI" ] ; then
            
        GET_SI="scripts/conf/SELECTED_SI_INFO"
       
        if [ ! -f $GET_SI ]  ; then
          echo
          echo -e "\e[91m Missing $GET_SI ! \e[39m "
          echo -e "\e[91m You can use the command [[ ./scripts/01_use_si.sh si=WhichSI ]] to set the var WhichSI ! \e[39m " 
        fi
        
        SI=$(head -1 $GET_SI)        
            
        if [ "$SI" == "" ] ; then  
          SI="$ROOT_PATH/SI" 
        fi
    else
       SI="$ROOT_PATH/SI/$WhichSI"     
    fi
      
    ## Used for BACH PROCESSING
    TMP_OBDA_FOLDER="$WORK_TMP/obda_tmp"
        
    ## TRANSFERT TO USE SCRIPT
    mkdir -p $TMP_OBDA_FOLDER/
        
    ## Specs Location 
    INPUT_SPEC="$SI/input"
         
    ## Temp Specs Folder
    INPUT_TEMP_SPEC="$WORK_TMP/input_tmp"
                  
    ## Output OBDA files 
    OUTPUT_OBDA="$SI/output/01_obda"
         
    DEFAULT_MAPPING_NAME="mapping.$EXTENSION_OBDA"
        
    ## Connexion 
    CONNECTION_FILE_PATTERN="$INPUT_SPEC/connexion/connexion"
    CONNECTION_FILE="$CONNECTION_FILE_PATTERN.$EXTENSION_SPEC"
    
    # ONTOP_FOLDER="data/ontop"
    # CORESE_FOLDER="data/corese"    
                    
    SI_FILE=$SI/csv/$CSV_FILE_NAME
    OUT_VALIDATE_CSV=$SI/csv/$VALIDE_CSV_FILE_NAME
        
    if [ ! -f $SI_FILE ]; then
      echo
      echo -e "\e[91m --> CSV not found at path : $SI_FILE ! Abort \e[39m"
      echo
      EXIT
    fi
	
    chmod -R +x $SCRIPT_PATH/*
        
    # $SCRIPT_PATH/utils/check_commands.sh java curl psql-mysql mvn
        
    # $SCRIPT_PATH/12_docker_nginx.sh stop
    
    # $SCRIPT_PATH/12_docker_nginx.sh start
      
    $SCRIPT_PATH/05_init_si_data.sh "-a" "-f"
            
    $SCRIPT_PATH/11_nano_start_stop.sh stop
      
    $SCRIPT_PATH/03_extract_prefixs_from_owl.sh
                
    echo
    echo -e "\e[94m --> Treat CSV : $SI_FILE \e[39m"
    echo
    sleep 0.1
      
    $SCRIPT_PATH/04_corese_clone_valide_csv.sh csv="$SI_FILE"                       \
                                               out="$OUT_VALIDATE_CSV"              \
                                               csv_sep="$CSV_SEP"                   \
                                               intra_separators="$INTRA_SEPARATORS" \
                                               columns="$COLUMNS_TO_VALIDATE"
    
    if [ ! -f $OUT_VALIDATE_CSV ]; then
      echo
      echo -e "\e[91m --> Error When validate CSV : $SI_FILE ! Abort \e[39m"
      echo
      EXIT
    fi
            
    $SCRIPT_PATH/02_build_config.sh  ip=$IP_HOST namespace=$NAME_SPACE rw=$Read_Write_Port ro=$Read_Only_Port # TO DELL
                            
       	
    ########################"
    ########################
    #  DDR                ##
    ########################
    ########################	
	
    for specs in `find $INPUT_SPEC/ -type d -name "*shared*" -not -path "*/DOI" ` ;  do  
        
        # Copy Connexion File ( graphml ) [ Optionnal ]

         if [  -f "$CONNECTION_FILE"  ]; then
            cp -p $CONNECTION_FILE $INPUT_TEMP_SPEC
         fi

         for specs_ddr in `find $specs -type f -name "*.$EXTENSION_SPEC" ` ;  do 

           cp $specs_ddr $INPUT_TEMP_SPEC
              
         done

         # Check if $INPUT_SPEC Folder contains more than 0 file ( connexion.graphml included [ Optionnal ] )

         if [ `ls -l $INPUT_TEMP_SPEC --ignore=$(basename $CONNECTION_FILE) | egrep -c '^-'` -gt 0 ] ; then 
              
            #SPEC_FOLDER="$(dirname "$specs")"                     
                 
            if [ -f $specs/$CLASS_FILE ] ; then
                    
              LINE_ONE=$(head -n 1 $specs/$CLASS_FILE ) 
              LINE_TWO=$(sed -n '2p' $specs/$CLASS_FILE )
                       
              IFS=$'=' read -ra KEY_VALUE <<< "$LINE_ONE" 
              CLASS_VALUE=${KEY_VALUE[1]}
              IFS=$'=' read -ra KEY_VALUE <<< "$LINE_TWO" 
              DISCRIMINATOR_COLUMN=${KEY_VALUE[1]}
                
            fi 	

            $SCRIPT_PATH/06_gen_mapping.sh input="$INPUT_TEMP_SPEC"                    \
                                           output="$OUTPUT_OBDA/$DEFAULT_MAPPING_NAME" \
                                           csvFileName="$OUT_VALIDATE_CSV"             \
                                           ext=".$EXTENSION_SPEC"                      \
                                           class="$CLASS_VALUE"                        \
                                           column="$DISCRIMINATOR_COLUMN"              \
                                           connecFileName=$CONNEC_FILE_NAME            \
                                           version=$YED_GEN_ONTOP_VERSION              

            # FOR EACH OBDA MAPPING GENERATED FROM SPEC - obdaMapping in `find $OUTPUT_OBDA/* -type f

            for obdaMapping in ` find $OUTPUT_OBDA -type f -name "*.$EXTENSION_OBDA" ` ; do
            
            # for obdaMapping in ` ls -p $OUTPUT_OBDA | grep -v / ` ; do
            
               echo ;  echo " --> Treat OBDA File  -  $obdaMapping " ; echo
                                  
               cp -rf $obdaMapping $TMP_OBDA_FOLDER/

               mv $TMP_OBDA_FOLDER/$(basename $obdaMapping) $TMP_OBDA_FOLDER/$DEFAULT_MAPPING_NAME

               
               read_type_connection_properties "$SI/$CONNEC_FILE_NAME"

               echo " --> $CONNECTION_TYPE"

               if [ "$CONNECTION_TYPE" == "DATARIV_CSV_Q"     -o  "$CONNECTION_TYPE" == "datariv_csv_q"     -o \
                    "$CONNECTION_TYPE" == "DATARIV_CSV_H2"    -o  "$CONNECTION_TYPE" == "datariv_csv_h2"    -o \
                    "$CONNECTION_TYPE" == "DATARIV_CSV_PG"    -o  "$CONNECTION_TYPE" == "datariv_csv_pg"    -o \
                    "$CONNECTION_TYPE" == "DATARIV_CSV_MYSQL" -o  "$CONNECTION_TYPE" == "datariv_csv_mysql" -o \
                    "$CONNECTION_TYPE" == "DATARIV_DB_PG"     -o  "$CONNECTION_TYPE" == "datariv_pg"        -o \
                    "$CONNECTION_TYPE" == "DATARIV_DB_MYSQL"  -o  "$CONNECTION_TYPE" == "datariv_db_mysql"  ] ; then 
   
                    echo ; echo " --> Call dataRiv... ( Shared Models ) "

                    if  [ "$DATARIV_ONLY_ENTAILMENT" == "only_entailment" -a \
                          "$DATARIV_ENTAILMENT"      == "e"           ] ; then 
                            echo 
                            echo "  DATARIV_ONLY_ENTAILMENT == only_entailment   "
                            echo "  DISABLE DATARIV_ENTAILMENT_RM                "
                            echo "  DISABLE DATARIV_ENTAILMENT_RM_ON_LOAD        "
                            DATARIV_ENTAILMENT_RM=""
                            DATARIV_ENTAILMENT_RM_ON_LOAD=""
                            # Need Ontology in order to run Sparql Queries
                            DATARIV_ENTAILMENT_OUT_ONTOLOGY="e.out_ontology"
                            echo
                    fi
                         
                    $SCRIPT_PATH/16_data-riv_csv_gen_triples.sh obda="$TMP_OBDA_FOLDER/$DEFAULT_MAPPING_NAME"      \
                                                                type="$CONNECTION_TYPE"                            \
                                                                page_size="$DATARIV_PAGE_SIZE"                     \
                                                                fragment="$DATARIV_FRAGMENT"                       \
                                                                flush_count="$DATARIV_FLUSH_COUNT"                 \
                                                                xms="$DATARIV_XMS"                                 \
                                                                xmx="$DATARIV_XMX"                                 \
                                                                log_level="$DATARIV_LOG_LEVEL"                     \
                                                                csv_separator="$DATARIV_CSV_SEPARATOR"             \
                                                                csv_directory="$DATARIV_CSV_DIRECTORY"             \
                                                                jdbc_url="$DATARIV_JDBC_URL"                       \
                                                                jdbc_user="$DATARIV_JDBC_USER"                     \
                                                                jdbc_password="$DATARIV_JDBC_PASSWORD"             \
                                                                "$DATARIV_DEBUG"                                   \
                                                                parallelism=$DATARIV_PARALLELISM                   \
                                                                $DATARIV_ENTAILMENT                                \
                                                                e.peek=$DATARIV_ENTAILMENT_PEEK                    \
                                                                e.parallelism=$DATARIV_ENTAILMENT_PARALLELISM      \
                                                                $DATARIV_ENTAILMENT_RM                             \
                                                                $DATARIV_ENTAILMENT_RM_ON_LOAD                     \
                                                                $DATARIV_ENTAILMENT_OUT_ONTOLOGY                   \
                                                                $DATARIV_DEBUG                                     \
                                                                $DATARIV_INDEX_COLUMNS                             \
                                                                must_not_be_empty="$MUST_NOT_BE_EMPTY_NODES"       \
                                                                $DATARIV_ENTAILMENT_DISABLE_CACHE_GRAH             \
                                                                e.engine_level="$DATARIV_ENTAILMENT_ENGINE_LEVEL"  \
                                                                my_sql_version=$DATARIV_MY_SQL_VERSION             \
                                                                $DATARIV_ONLY_ENTAILMENT                           \
                                                                output="$SI/output/03_corese/dataRiv.ttl"
                    
                    TMP_EXTRACTED_TTL="$SI/output/03_corese/.tmp_sem_extraction/"
                    
                    if  [ "$DATARIV_ONLY_ENTAILMENT" == "only_entailment" -a \
                          "$DATARIV_ENTAILMENT"      == "e"               -a \
                          ! -z "$(find $TMP_EXTRACTED_TTL -mindepth 1 -iname '*.ttl' -print -quit 2>/dev/null)" ] ;  then 
                                
                         # Then we need to copy the rest of already extracted triples 
                         echo " Shared Data : MOVE [$TMP_EXTRACTED_TTL/*.*] -- TO --> [$SI/output/03_corese/] "
                         mv  $TMP_EXTRACTED_TTL/*.*  $SI/output/03_corese/
                            
                         echo "- Delete the Empty Dir : $TMP_EXTRACTED_TTL"
                         rm -rf $TMP_EXTRACTED_TTL

                         # Disable Output_Ontology ( Not Needed, Already Generated By Datariv : Enabled by this script )
                         DATARIV_ENTAILMENT_OUT_ONTOLOGY="" 
                    fi
                        
                    # Else Ttl are directly producced in output/03_corese/
                    if [ -z "$(find $SI/output/03_corese/ -iname '*.ttl' 2>/dev/null)" ]; then
                        echo "- Empty Extraction ! EMPTY_NODE_DETECTED => Break "
                        echo 
                        $SCRIPT_PATH/05_init_si_data.sh "-a" 
                        EMPTY_NODE_DETECTED="true"
                        break 
                    fi
                    
               else

                    echo " Call Ontop...   "
                    
                    $SCRIPT_PATH/07_ontop_gen_triples.sh obda="$TMP_OBDA_FOLDER/$DEFAULT_MAPPING_NAME" \
                                                         query="$ONTOP_QUERY"                          \
                                                         ttl="$ONTOP_TTL_FORMAT"                       \
                                                         batch="$ONTOP_BATCH"                          \
                                                         pageSize="$ONTOP_PAGE_SIZE"                   \
                                                         fragment="$ONTOP_FRAGMENT"                    \
                                                         flushCount="$ONTOP_FLUSH_COUNT"               \
                                                         merge="$ONTOP_MERGE"                          \
                                                         xms="$ONTOP_XMS"                              \
                                                         xmx="$ONTOP_XMX"                              \
                                                         connection="$SI/$CONNEC_FILE_NAME"            \
                                                         log_level="$ONTOP_LOG_LEVEL"                  \
                                                         must_not_be_empty="$MUST_NOT_BE_EMPTY_NODES"  \
                                                         "$ONTOP_DEBUG" 
                                                         
                    $SCRIPT_PATH/08_corese_infer.sh query="$CORESE_QUERY"             \
                                                    peek="$CORESE_PEEK"               \
                                                    fragment="$CORESE_FRAGMENT"       \
                                                    format="$CORESE_FORMAT"           \
                                                    flushCount="$CORESE_FLUSH_COUNT"  \
                                                    xms="$CORESE_XMS"                 \
                                                    xmx="$CORESE_XMX"                 \
                                                    "$CORESE_IGNORE_LINE_BREAK" 
               fi
                                              

               CURRENT_DATE_TIME=`date +%d_%m_%Y__%H_%M_%S`
               
               mkdir -p $SI/output/03_corese/shared/$CURRENT_DATE_TIME
                         
               mv $SI/output/03_corese/*.* $SI/output/03_corese/shared/$CURRENT_DATE_TIME 
                       
               $SCRIPT_PATH/05_init_si_data.sh "-a" 
               
               sleep 0.1

            done
               
         fi
            
    done

    ########################"
    ########################
    #  THE REST SPECS     ##
    ########################
    ########################
	
    if [ "$EMPTY_NODE_DETECTED" == "true" ] ; then
       echo
       echo " - MUST_NOT_BE_EMPTY_NODE : DETECTED "
       echo " - SI : [ $SI ] Will be Ignored !    "
       echo
    fi
     
    if [ "$EMPTY_NODE_DETECTED" != "true" ] ; then

    for specs in `find $INPUT_SPEC/* -type d -not -name '*connexion*' -not -name '*shared*' -not -path "*/shared/*" -not -path "*/DOI" `; do
             
        if [ `ls -l $specs | egrep -c '^-'` -gt 0 ] ; then           
         
          echo " + Treat Specs Folder --> $specs "
              
          # Copy Connexion File ( graphml ) [ Optionnal ]
              
          if [  -f $CONNECTION_FILE  ]; then
	      cp -p $CONNECTION_FILE $INPUT_TEMP_SPEC
	    fi               
              
        # FOR EACH SPEC - Copy File by File from $specs folder to files $INPUT_TEMP_SPEC folder

        for spec in `find $specs/*.$EXTENSION_SPEC -type f `; do
            connecFileName=$CONNEC_FILE_NAME
            cp $spec $INPUT_TEMP_SPEC
              
        done
              
        # Check if $INPUT_SPEC Folder contains more than 0 files ( connexion.graphml included [ Optionnal ]) 
               
        if [ `ls -l $INPUT_TEMP_SPEC --ignore=$(basename $CONNECTION_FILE) | egrep -c '^-'` -gt 0 ] ; then 
               
              #SPEC_FOLDER="$(dirname "$specs")"                     
                    
              if [ -f $specs/$CLASS_FILE ] ; then
                    
                 LINE_ONE=$(head -n 1 $specs/$CLASS_FILE ) 
                 LINE_TWO=$(sed -n '2p' $specs/$CLASS_FILE )
                       
                 IFS=$'=' read -ra KEY_VALUE <<< "$LINE_ONE" 
                 CLASS=${KEY_VALUE[1]}
                 IFS=$'=' read -ra KEY_VALUE <<< "$LINE_TWO" 
                 DISCRIMINATOR_COLUMN=${KEY_VALUE[1]}
                       
              fi   
		
              $SCRIPT_PATH/06_gen_mapping.sh input="$INPUT_TEMP_SPEC"                  \
                                             output=$OUTPUT_OBDA/$DEFAULT_MAPPING_NAME \
                                             csvFileName=$VALIDE_CSV_FILE_NAME         \
                                             ext=.$EXTENSION_SPEC                      \
                                             class="$CLASS"                            \
                                             column="$DISCRIMINATOR_COLUMN"            \
                                             connecFileName=$CONNEC_FILE_NAME          \
                                             version=$YED_GEN_ONTOP_VERSION            

              # FOR EACH OBDA MAPPING GENERATED FROM SPEC - obdaMapping in `find $OUTPUT_OBDA/* -type f `
              
     
              for obdaMapping in ` find $OUTPUT_OBDA -type f -name "*.$EXTENSION_OBDA" ` ; do # -printf "%f\n"
              
                 echo ;  echo " + Treat OBDA File -->  $obdaMapping " 
                           
                 cp -rf $obdaMapping $TMP_OBDA_FOLDER/
                       
                 mv $TMP_OBDA_FOLDER/$(basename $obdaMapping) $TMP_OBDA_FOLDER/$DEFAULT_MAPPING_NAME
              
                 read_type_connection_properties "$SI/$CONNEC_FILE_NAME"

                 if [ "$CONNECTION_TYPE" == "DATARIV_CSV_Q"     -o  "$CONNECTION_TYPE" == "datariv_csv_q"     -o \
                      "$CONNECTION_TYPE" == "DATARIV_CSV_H2"    -o  "$CONNECTION_TYPE" == "datariv_csv_h2"    -o \
                      "$CONNECTION_TYPE" == "DATARIV_CSV_PG"    -o  "$CONNECTION_TYPE" == "datariv_csv_pg"    -o \
                      "$CONNECTION_TYPE" == "DATARIV_CSV_MYSQL" -o  "$CONNECTION_TYPE" == "datariv_csv_mysql" -o \
                      "$CONNECTION_TYPE" == "DATARIV_DB_PG"     -o  "$CONNECTION_TYPE" == "datariv_pg"        -o \
                      "$CONNECTION_TYPE" == "DATARIV_DB_MYSQL"  -o  "$CONNECTION_TYPE" == "datariv_db_mysql"  ]  ; then 
   
                    echo ; echo " --> Call dataRiv... ( Data Models ) "
                    
                    if  [ "$DATARIV_ONLY_ENTAILMENT" == "only_entailment" -a \
                          "$DATARIV_ENTAILMENT"      == "e"           ] ; then 
                            echo 
                            echo "  DATARIV_ONLY_ENTAILMENT == only_entailment   "
                            echo "  DISABLE DATARIV_ENTAILMENT_RM                "
                            echo "  DISABLE DATARIV_ENTAILMENT_RM_ON_LOAD        "
                            DATARIV_ENTAILMENT_RM=""
                            DATARIV_ENTAILMENT_RM_ON_LOAD=""
                            echo
                    fi
                    
                    $SCRIPT_PATH/16_data-riv_csv_gen_triples.sh obda="$TMP_OBDA_FOLDER/$DEFAULT_MAPPING_NAME"       \
                                                                type="$CONNECTION_TYPE"                             \
                                                                page_size="$DATARIV_PAGE_SIZE"                      \
                                                                fragment="$DATARIV_FRAGMENT"                        \
                                                                flush_count="$DATARIV_FLUSH_COUNT"                  \
                                                                xms="$DATARIV_XMS"                                  \
                                                                xmx="$DATARIV_XMX"                                  \
                                                                log_level="$DATARIV_LOG_LEVEL"                      \
                                                                csv_separator="$DATARIV_CSV_SEPARATOR"              \
                                                                csv_directory="$DATARIV_CSV_DIRECTORY"              \
                                                                jdbc_url="$DATARIV_JDBC_URL"                        \
                                                                jdbc_user="$DATARIV_JDBC_USER"                      \
                                                                jdbc_password="$DATARIV_JDBC_PASSWORD"              \
                                                                "$DATARIV_DEBUG"                                    \
                                                                parallelism=$DATARIV_PARALLELISM                    \
                                                                $DATARIV_ENTAILMENT                                 \
                                                                e.peek=$DATARIV_ENTAILMENT_PEEK                     \
                                                                e.parallelism=$DATARIV_ENTAILMENT_PARALLELISM       \
                                                                $DATARIV_ENTAILMENT_RM                              \
                                                                $DATARIV_ENTAILMENT_RM_ON_LOAD                      \
                                                                $DATARIV_ENTAILMENT_OUT_ONTOLOGY                    \
                                                                $DATARIV_DEBUG                                      \
                                                                $DATARIV_INDEX_COLUMNS                              \
                                                                must_not_be_empty="$MUST_NOT_BE_EMPTY_NODES"        \
                                                                $DATARIV_ENTAILMENT_DISABLE_CACHE_GRAH              \
                                                                e.engine_level="$DATARIV_ENTAILMENT_ENGINE_LEVEL"   \
                                                                my_sql_version=$DATARIV_MY_SQL_VERSION              \
                                                                $DATARIV_ONLY_ENTAILMENT                            \
                                                                output="$SI/output/03_corese/dataRiv.ttl"
                        
                    TMP_EXTRACTED_TTL="$SI/output/03_corese/.tmp_sem_extraction/"

                    if  [ "$DATARIV_ONLY_ENTAILMENT" == "only_entailment" -a \
                          "$DATARIV_ENTAILMENT"      == "e"               -a \
                          ! -z "$(find $TMP_EXTRACTED_TTL -mindepth 1 -iname '*.ttl' -print -quit 2>/dev/null)" ] ;  then 
                            
                        # Then we need to copy the rest of already extracted triples 
                        echo " Data Models : MOVE [ $TMP_EXTRACTED_TTL/*.* ] -- TO --> [ $SI/output/03_corese/ ] "
                        mv  $TMP_EXTRACTED_TTL/*.*  $SI/output/03_corese/
                           
                        echo "- Delete the Empty Dir : $TMP_EXTRACTED_TTL"
                        rm -rf $TMP_EXTRACTED_TTL
                    fi
                     
                    # Else Ttl are diractly producced in $SI/output/03_corese/
                    if [ -z "$(find $SI/output/03_corese/ -iname '*.ttl' 2>/dev/null)" ]; then
                         echo "- Empty Extraction ! ! EMPTY_NODE_DETECTED => Continue "
                         echo 
                         $SCRIPT_PATH/05_init_si_data.sh "-a"
                         EMPTY_NODE_DETECTED="true"
                         continue 
                    fi
                    
                 else

                    echo " Call Ontop...   "
                    
                    $SCRIPT_PATH/07_ontop_gen_triples.sh obda="$TMP_OBDA_FOLDER/$DEFAULT_MAPPING_NAME" \
                                                         query="$ONTOP_QUERY"                          \
                                                         ttl="$ONTOP_TTL_FORMAT"                       \
                                                         batch="$ONTOP_BATCH"                          \
                                                         pageSize="$ONTOP_PAGE_SIZE"                   \
                                                         fragment="$ONTOP_FRAGMENT"                    \
                                                         flushCount="$ONTOP_FLUSH_COUNT"               \
                                                         merge="$ONTOP_MERGE"                          \
                                                         xms="$ONTOP_XMS"                              \
                                                         xmx="$ONTOP_XMX"                              \
                                                         connection="$SI/$CONNEC_FILE_NAME"            \
                                                         log_level="$ONTOP_LOG_LEVEL"                  \
                                                         must_not_be_empty="$MUST_NOT_BE_EMPTY_NODES"  \
                                                         "$ONTOP_DEBUG" 
                                                         
                    $SCRIPT_PATH/08_corese_infer.sh query="$CORESE_QUERY"              \
                                                    peek="$CORESE_PEEK"                \
                                                    fragment="$CORESE_FRAGMENT"        \
                                                    format="$CORESE_FORMAT"            \
                                                    flushCount="$CORESE_FLUSH_COUNT"   \
                                                    xms="$CORESE_XMS"                  \
                                                    xmx="$CORESE_XMX"                  \
                                                    "$CORESE_IGNORE_LINE_BREAK" 
                                                 
                 fi
               
                                
                 $SCRIPT_PATH/02_build_config.sh  ip=$IP_HOST namespace=$NAME_SPACE rw=$Read_Write_Port ro=$Read_Only_Port 

                 $SCRIPT_PATH/11_nano_start_stop.sh start rw 12 12 28
                    
                 $SCRIPT_PATH/09_load_data.sh
             
                 SPARQL_FILE_PATH=$(dirname "${spec}")/$SPARQL_FILE_NAME            
                 
                 CURRENT_DATE_TIME=`date +%d_%m_%Y__%H_%M_%S`
                      
                 # $SCRIPT_PATH/10_queryer.sh $SPARQL_FILE_PATH $SI/output/04_synthesis/$(basename $obdaMapping)"_"$CURRENT_DATE_TIME.ttl
                     
                 $SCRIPT_PATH/10_queryer.sh query_path="$SPARQL_FILE_PATH"                                                     \
                                            output="$SI/output/04_synthesis/$(basename $obdaMapping)"_"$CURRENT_DATE_TIME.ttl" \
                                            accept="text/rdf+n3"

                 # $SCRIPT_PATH/11_nano_start_stop.sh stop
                
                 $SCRIPT_PATH/05_init_si_data.sh "-output" "-tmp"
              
                 sleep 0.1
                                                                       
              done                     
                         
              $SCRIPT_PATH/05_init_si_data.sh "-a"
                    
          fi
                                      
       fi
            
    done
      
    fi 
    
    # $SCRIPT_PATH/12_docker_nginx.sh stop

    $SCRIPT_PATH/05_init_si_data.sh "-a" "-f"
  
    ## read -rsn1

    echo 
    echo 
    echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX "
    echo
    echo " COBY PIPELINE SYNTHESIS FINISHED FOR THE SI : $WhichSI "
    echo
    echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX "
    echo 
    echo 

