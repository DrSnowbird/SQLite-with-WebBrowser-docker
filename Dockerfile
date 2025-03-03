ARG BASE=${BASE:-openkbs/python-nonroot-docker}
FROM ${BASE}

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

###############################
#### ---- App: (ENV)  ---- ####
###############################
USER ${USER:-developer}
WORKDIR ${HOME:-/home/developer}

ENV APP_HOME=${APP_HOME:-$HOME/app}
ENV APP_MAIN=${APP_MAIN:-setup.sh}

#################################
#### ---- App: (common) ---- ####
#################################
WORKDIR ${APP_HOME}
RUN python -u -m pip install --upgrade pip

###############################
#### ---- App Setup:  ---- ####
###############################
COPY --chown=$USER:$USER ./app/requirements.txt $HOME/requirements.txt
COPY --chown=$USER:$USER ./bin $HOME/bin

#RUN $HOME/bin/pre-load-virtualenv.sh && \

RUN if [ -s $HOME/requirements.txt ]; then \
        pip install --no-cache-dir --user -r $HOME/requirements.txt ; \
    fi; 
 
ENV PATH=${HOME}/.local/bin:${PATH}


RUN sudo apt-get update && \
    sudo apt-get install -y sqlite3

#########################################
##### ---- Setup: Entry Files  ---- #####
#########################################
COPY --chown=${USER}:${USER} docker-entrypoint.sh /
COPY --chown=${USER}:${USER} ${APP_MAIN} ${APP_HOME}/setup.sh

RUN sudo chown -R ${USER}:${USER} ${APP_HOME} && \
    sudo chmod +x /docker-entrypoint.sh ${APP_HOME}/setup.sh 

#########################################
##### ---- Docker Entrypoint : ---- #####
#########################################
ENTRYPOINT ["/docker-entrypoint.sh"]

#####################################
##### ---- user: developer ---- #####
#####################################
WORKDIR ${APP_HOME}
USER ${USER}

#############################################
#############################################
#### ---- App: (Customization here) ---- ####
#############################################
#############################################
#### (you customization code here!) #########
COPY --chown=$USER:$USER  ./app $HOME/app

######################
#### (Test only) #####
######################
#CMD ["/bin/bash"]
######################
#### (RUN setup) #####
######################
#CMD ["setup.sh"]
CMD ["sh -c", "${APP_HOME}/run-sqlite-with-browser.sh"]

