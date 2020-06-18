#!/bin/bash
  
    set -e 

    SCRIPT_PATH="../scripts"
    SI_PATHS="../SI"
    
    NAME_SPACE="Sol"
    IP_HOST="localhost"    

    ################################################################
    # Arbo SI Configuration Ex
    ################################################################
    #
    #   + si_name
    #     - connection.txt
    #     + csv
    #       - semantic_si.csv
    #     + input
    #       + shared
    #         + Directory_01
    #           - mod.graphml
    #       + variables
    #         + variable_01
    #           - variable_01.graphml 
    #           - class.txt 
    #           - sparql.txt
    #         + variable_02
    #           - variable_02.graphml 
    #           - class.txt 
    #           - sparql.txt
    #
    ################################################################
    ################################################################
    
    
    ################################################################
    #
    ### CONFIGURATION ##############################################
    #
    ################################################################    

    # Port 
    RW="7777"
    RO="8888"
    # Database 
    DATA_BASE="postgresql" # Alternative : "mysql"
    # Extensions :
    EXT_OBDA="obda"
    EXT_GRAPH="graphml"
    # Class File ( Discriminators )
    CLASS_FILE_NAME="class.txt"
    SPARQL_FILE_NAME="sparql.txt"
    ## CSV Config
    CSV_SEP=";"
    INTRA_CSV_SEP=" -intra_sep , -intra_sep < -intra_sep > " 
    # COLUMNSTO_VALIDATE=" -column 0 -column 1 -column 2 -column 4 -column 6 -column 7 -column 8 -column 10 "
    INPUT_CSV_FILE_NAME="semantic_si.csv"
    OUTPUT_VALIDE_CSV_FILE_NAME="pipeline_si.csv"
    # Connection
    CONNEC_FILE_NAME="connection.txt"
    
       
    ONTOP_MUST_NOT_BE_EMPTY=" (1) , (2) "
     
    CORESE_IGNORE_BREAK_LINE="corese_ignore_line_break" # Empty to disable     
    
    # Corese ARGS
    CORESE_QUERY=${CORESE_QUERY:-"SELECT ?S ?P ?O { ?S ?P ?O . filter( !isBlank(?S) ) . filter( !isBlank(?O) )  } "}
    CORESE_PEEK=${CORESE_PEEK:-"-peek 6 "}
    CORESE_FRAGMENT=${CORESE_FRAGMENT:-"-f 1000000 "}    
    CORESE_FORMAT=${CORESE_FORMAT:-"-F ttl "}
    CORESE_FLUSH_COUNT=${CORESE_FLUSH_COUNT:-"-flushCount 250000"}    
    CORESE_XMS=${CORESE_XMS:-"15g"}
    CORESE_XMX=${CORESE_XMX:-"15g"}
    
    # dataRiv 
    DATARIV_LOG_LEVEL="INFO"
    DATARIV_PAGE_SIZE="100000"
    DATARIV_FRAGMENT="1000000"
    DATARIV_FLUSH_COUNT="100000"
    DATARIV_PARALLELISM="0"     # 0 : Available cores. 1 : No parallelism. > 1 Parallelism "" 
    DATARIV_INDEX_COLUMNS="index_columns"
    DATARIV_ENTAILMENT="" # "datariv_entailment" # Disable : ""
    DATARIV_ENTAILMENT_PARALLELISM="2"
    DATARIV_ENTAILMENT_PEEK="2"
    DATARIV_ENTAILMENT_RM="datariv_entailement_rm"
    DATARIV_ENTAILMENT_RM_ON_LOAD="datariv_entailment_rm_on_load"
    DATARIV_ENTAILMENT_OUT_ONTOLOGY="datariv_entailment_out_ontology" # ""
    DATARIV_ENTAILMENT_ENGINE_LEVEL=""        # RDFS , OWL_RL , OWL_RL_LITE , OWL_TL_FULL
    DATARIV_ENTAILMENT_DISABLE_CACHE_GRAPH="" # "datariv_entailment_disable_cache_graph" 
    
    DATARIV_ONLY_ENTAILMENT="" # "datariv_only_entailment"
    
    DATARIV_DEBUG="" # datariv_debug 
    
    DATARIV_XMS="8g"
    DATARIV_XMX="8g"
    
    ################################################
    ## DO NOT TOUCH ################################
    ################################################
    ################################################
    #
    # SCRIPT #######################################
    #
    ################################################    
    ################################################    
    
    echo 
    echo " 00 ============================ 00 "
    echo " ** ============================ ** "
    echo " ||   ____   ____  ___  _     __ || "
    echo " ||  / ___| / __ \|  _ \ \   / / || "
    echo " || | |    | |  | | |_) \ \_/ /  || "
    echo " || | |    | |  | |  _<  \   /   || "
    echo " || | |___ | |__| | |_) | | |    || "
    echo " ||  \____| \____/|____/  |_| v1 || "
    echo " || Portal                       || "
    echo " ** ============================ ** "
    echo " 00 ============================ 00 "   
   
    CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cd $CURRENT_PATH
    ROOT_PATH="${CURRENT_PATH/}"
  
    EXIT() {
     if [ $PPID = 0 ] ; then exit ; fi
     parent_script=`ps -ocommand= -p $PPID | awk -F/ '{print $NF}' | awk '{print $1}'`
     if [ $parent_script = "bash" ] ; then
         echo; echo -e " \e[90m exited by : $0 \e[39m " ; echo
         exit 2
     else
         if [ $parent_script != "java" ] ; then 
            echo ; echo -e " \e[90m exited by : $0 \e[39m " ; echo
            kill -9 `ps --pid $$ -oppid=`;
            exit 2
         fi
         echo " Coby Exited "
         exit 2
     fi
    } 
    
    #####################################################
    #####################################################
    # COBY PIPELINE 
    #####################################################
    #####################################################
     
    if [ ! -d "$SI_PATHS" ]; then 
      echo  
      echo -e "\e[93m ERROR ### \e[32m "
      echo -e "\e[93m  =>> Missning Modelization. No [$SI_PATHS] Folder Provided ### \e[32m "
      EXIT
    fi
    
    
    ## CLEAN ALL OUTPUT FOLDERS 
    echo 
    for outputDirectory in `find ../SI/ -name "output" -type d ` ;  do  
    
         echo 
         echo " + Remove The Output Directory : $outputDirectory " 
         rm -rf $outputDirectory
           
   done
         
         
         
    SI=${1:-""}
   
    if [ -z "$SI" -o "$SI" == "ALL_SI" ] ; then
    
        for SI in `ls "$SI_PATHS" --ignore "ontology" --ignore "SI.txt" `;   do

         ./synthesis_extractor_process.sh ip=$IP_HOST                                                      \
                                          namespace=$NAME_SPACE                                            \
                                          ro=$RO                                                           \
                                          rw=$RW                                                           \
                                          si=$SI                                                           \
                                          db=$DATA_BASE                                                    \
                                          ext_obda=$EXT_OBDA                                               \
                                          ext_graph=$EXT_GRAPH                                             \
                                          class_file_name=$CLASS_FILE_NAME                                 \
                                          sparql_file_name=$SPARQL_FILE_NAME                               \
                                          csv_file_name=$INPUT_CSV_FILE_NAME                               \
                                          valide_csv_file_name=$OUTPUT_VALIDE_CSV_FILE_NAME                \
                                          csv_sep=$CSV_SEP                                                 \
                                          intra_separators="$INTRA_CSV_SEP"                                \
                                          columns="$COLUMNSTO_VALIDATE"                                    \
                                          connec_file_name=$CONNEC_FILE_NAME                               \
                                                                                                           \
                                          corese_xms="$CORESE_XMS"                                         \
                                          corese_xmx="$CORESE_XMX"                                         \
                                          corese_query="$CORESE_QUERY"                                     \
                                          corese_peek="$CORESE_PEEK"                                       \
                                          corese_fragment="$CORESE_FRAGMENT"                               \
                                          corese_flush_count="$CORESE_FLUSH_COUNT"                         \
                                          corese_format="$CORESE_FORMAT"                                   \
                                          "$CORESE_IGNORE_BREAK_LINE"                                      \
                                                                                                           \
                                          must_not_be_empty="$ONTOP_MUST_NOT_BE_EMPTY"                     \
                                                                                                           \
                                          datariv_page_size="$DATARIV_PAGE_SIZE"                           \
                                          datariv_fragment="$DATARIV_FRAGMENT"                             \
                                          datariv_flush_count="$DATARIV_FLUSH_COUNT"                       \
                                          datariv_xms="$DATARIV_XMS"                                       \
                                          datariv_xmx="$DATARIV_XMX"                                       \
                                          datariv_log_level="$DATARIV_LOG_LEVEL"                           \
                                          datariv_parallelism=$DATARIV_PARALLELISM                         \
                                          $DATARIV_ENTAILMENT                                              \
                                          datariv_entailment_parallelism=$DATARIV_ENTAILMENT_PARALLELISM   \
                                          datariv_entailment_peek=$DATARIV_ENTAILMENT_PEEK                 \
                                          datariv_entailment_engine_level=$DATARIV_ENTAILMENT_ENGINE_LEVEL \
                                          $DATARIV_ENTAILMENT_DISABLE_CACHE_GRAPH                          \
                                          $DATARIV_ENTAILMENT_RM                                           \
                                          $DATARIV_ENTAILMENT_RM_ON_LOAD                                   \
                                          $DATARIV_ENTAILMENT_OUT_ONTOLOGY                                 \
                                          $DATARIV_INDEX_COLUMNS                                           \
                                          $DATARIV_ONLY_ENTAILMENT                                         \
                                          $DATARIV_DEBUG
                                          

                                          
        done 
        
        $SCRIPT_PATH/02_build_config.sh  ip=$IP_HOST namespace=$NAME_SPACE rw=$RW ro=$RO 
         
        $SCRIPT_PATH/11_nano_start_stop.sh start rw 12 12 28
   
        echo
        echo
        echo 
        echo -e "\e[93m ######################################################################## \e[32m "
        echo -e "\e[93m ######################################################################## \e[32m "
        echo -e "\e[93m ######## LOADING ALL SYNTHESIS DATA #################################### \e[32m "
        echo -e "\e[93m ######################################################################## \e[32m "
        echo -e "\e[93m ######################################################################## \e[32m "
        echo 
        echo
        
        for synthesisDirectory in `find ../SI/ -name "04_synthesis" -type d ` ;  do  
    
                    echo ; echo -e "\e[93m Upload All Produced Sythesis at Path : $synthesisDirectory \e[32m " ; echo 
            
                    $SCRIPT_PATH/09_load_data.sh  from_directory="$synthesisDirectory" \
                                                  content_type="text/turtle"        
                                           
                    #  $SCRIPT_PATH/09_load_data.sh from_directory="$SI/output/04_synthesis/" ip="localhost" port="$Read_Write_Port" namespace=$NAME_SPACE content_type="text/turtle"
                    
                    ##   Supported Content : 
                    #### content_type=text/turtle 
                    #### content_type=application/rdf+xml 
                    #### content_type=text/rdf+n3
                    #### content_type=rdf/turtle
                    #### content=application/sparql-results+json 	
    
           
        done
         
        cd $CURRENT_PATH
        
        echo 
        echo 
        echo 
        echo -e "\e[93m ==================== \e[32m "
        echo -e "\e[93m == Querying Data === \e[32m "
        echo -e "\e[93m ==================== \e[32m "
        echo 
        echo 

        OUT=`readlink -f ../queryer/RESULT.txt `
        QUERY_PATH=`readlink -f ../queryer/sparql_full.txt `
            
        echo
        echo " QUERY_PATH : $QUERY_PATH "
        echo " OUT_RESULT : $OUT        "
        echo 
        
        $SCRIPT_PATH/10_queryer.sh ip="$IP_HOST"            \
                                   port="$Read_Only_Port"   \
                                   namespace="$NAME_SPACE"  \
                                   output="$OUT"            \
                                   query_path="$QUERY_PATH" \
                                   accept="text/csv"
        # Accept Examples :
        #   application/sparql-results+xml
        #   application/sparql-results+json, application/json
        #   application/x-binary-rdf-results-table
        #   text/tab-separated-values
        #   text/csv
    
           
        echo
         
        $SCRIPT_PATH/11_nano_start_stop.sh stop
                  
        $SCRIPT_PATH/11_nano_start_stop.sh start ro 12 12 28
  
        ## read -rsn1        
        
    else 
           ./synthesis_extractor_process.sh ip="$IP_HOST"                                                    \
                                            namespace="$NAME_SPACE"                                          \
                                            ro=$RO                                                           \
                                            rw=$RW                                                           \
                                            si=$SI                                                           \
                                            db=$DATA_BASE                                                    \
                                            ext_obda=$EXT_OBDA                                               \
                                            ext_graph=$EXT_GRAPH                                             \
                                            class_file_name=$CLASS_FILE_NAME                                 \
                                            sparql_file_name=$SPARQL_FILE_NAME                               \
                                            csv_file_name=$INPUT_CSV_FILE_NAME                               \
                                            valide_csv_file_name=$OUTPUT_VALIDE_CSV_FILE_NAME                \
                                            csv_sep=$CSV_SEP                                                 \
                                            intra_separators="$INTRA_CSV_SEP"                                \
                                            columns="$COLUMNSTO_VALIDATE"                                    \
                                            connec_file_name=$CONNEC_FILE_NAME                               \
                                                                                                             \
                                            corese_xms="$CORESE_XMS"                                         \
                                            corese_xmx="$CORESE_XMX"                                         \
                                            corese_query="$CORESE_QUERY"                                     \
                                            corese_peek="$CORESE_PEEK"                                       \
                                            corese_fragment="$CORESE_FRAGMENT"                               \
                                            corese_flush_count="$CORESE_FLUSH_COUNT"                         \
                                            corese_format="$CORESE_FORMAT"                                   \
                                            "$CORESE_IGNORE_BREAK_LINE"                                      \
                                                                                                             \
                                            must_not_be_empty="$ONTOP_MUST_NOT_BE_EMPTY"                     \
                                                                                                             \
                                            datariv_page_size="$DATARIV_PAGE_SIZE"                           \
                                            datariv_fragment="$DATARIV_FRAGMENT"                             \
                                            datariv_flush_count="$DATARIV_FLUSH_COUNT"                       \
                                            datariv_xms="$DATARIV_XMS"                                       \
                                            datariv_xmx="$DATARIV_XMX"                                       \
                                            datariv_log_level="$DATARIV_LOG_LEVEL"                           \
                                            datariv_parallelism=$DATARIV_PARALLELISM                         \
                                            $DATARIV_ENTAILMENT                                              \
                                            datariv_entailment_parallelism=$DATARIV_ENTAILMENT_PARALLELISM   \
                                            datariv_entailment_peek=$DATARIV_ENTAILMENT_PEEK                 \
                                            datariv_entailment_engine_level=$DATARIV_ENTAILMENT_ENGINE_LEVEL \
                                            $DATARIV_ENTAILMENT_DISABLE_CACHE_GRAPH                          \
                                            $DATARIV_ENTAILMENT_RM                                           \
                                            $DATARIV_ENTAILMENT_RM_ON_LOAD                                   \
                                            $DATARIV_ENTAILMENT_OUT_ONTOLOGY                                 \
                                            $DATARIV_INDEX_COLUMNS                                           \
                                            $DATARIV_ONLY_ENTAILMENT                                         \
                                            $DATARIV_DEBUG
                                        
       
           $SCRIPT_PATH/02_build_config.sh  ip=$IP_HOST namespace=$NAME_SPACE rw=$RW ro=$RO 
         
           $SCRIPT_PATH/11_nano_start_stop.sh start rw 12 12 28
           
           echo
           echo
           echo 
           echo -e "\e[93m ######################################################################## \e[32m "
           echo -e "\e[93m ######################################################################## \e[32m "
           echo -e "\e[93m ######## LOADING ALL SYNTHESIS DATA #################################### \e[32m "
           echo -e "\e[93m ######################################################################## \e[32m "
           echo -e "\e[93m ######################################################################## \e[32m "
           echo 
           echo
         
           if [ -d "$SI_PATHS/$SI/output/04_synthesis/" ] ; then 
          
             $SCRIPT_PATH/09_load_data.sh  from_directory="$SI_PATHS/$SI/output/04_synthesis/" \
                                           content_type="text/turtle"        
                                           
            #  $SCRIPT_PATH/09_load_data.sh from_directory="$SI/output/04_synthesis/" ip="localhost" port="$Read_Write_Port" namespace=$NAME_SPACE content_type="text/turtle"
            
            ##   Supported Content : 
            #### content_type=text/turtle 
            #### content_type=application/rdf+xml 
            #### content_type=text/rdf+n3
            #### content_type=rdf/turtle
            #### content=application/sparql-results+json 	
   
           fi
         
           cd $CURRENT_PATH
        
           echo 
           echo 
           echo 
           echo -e "\e[93m ==================== \e[32m "
           echo -e "\e[93m == Querying Data === \e[32m "
           echo -e "\e[93m ==================== \e[32m "
           echo 
           echo 
 

           OUT=`readlink -f ../queryer/RESULT.txt `
           QUERY_PATH=`readlink -f ../queryer/sparql_full.txt `
            
           echo
           echo -e " QUERY_PATH : $QUERY_PATH "
           echo -e " OUT_RESULT : $OUT        "
           echo 
        
           $SCRIPT_PATH/10_queryer.sh ip="$IP_HOST"            \
                                      port="$Read_Only_Port"   \
                                      namespace="$NAME_SPACE"  \
                                      output="$OUT"            \
                                      query_path="$QUERY_PATH" \
                                      accept="text/csv"
           # Accept Examples :
           #   application/sparql-results+xml
           #   application/sparql-results+json, application/json
           #   application/x-binary-rdf-results-table
           #   text/tab-separated-values
           #   text/csv
    
           
           echo
          
           $SCRIPT_PATH/11_nano_start_stop.sh stop
                  
           $SCRIPT_PATH/11_nano_start_stop.sh start ro 12 12 28
  
           ## read -rsn1
        
    fi
    
