FROM debian:buster

SHELL ["/bin/bash", "--login", "-c"]

RUN apt-get update && \
    # Install Ruby v1.9.3
    apt-get install -y --no-install-recommends rbenv ruby-all-dev ruby-build && \
    rbenv install 1.9.3-p286 && \
    gem install bundler && \
    # Install cheesy-parts dependencies
    apt-get install -y --no-install-recommends default-libmysqlclient-dev git jq moreutils && \
    # Install cheesy-parts
    git clone --depth 1 https://github.com/Team254/cheesy-parts.git && \
    cd cheesy-parts && \
    bundle update --bundler && \
    bundle update mysql2 --conservative && \
    bundle install && \
    jq '.global.enable_wordpress_auth = false' config.json | sponge config.json && \
    jq '.dev.members_url = ""' config.json | sponge config.json && \
    # Patches
    echo "DB.extension(:connection_validator)" >> db.rb && \
    echo "DB.pool.connection_validation_timeout = -1" >> db.rb
WORKDIR /cheesy-parts

# Set up the ENTRYPOINT
RUN apt-get install -y --no-install-recommends dumb-init
COPY entrypoint.sh wait-for-it.sh /
ENTRYPOINT ["dumb-init", "/entrypoint.sh"]

CMD ["start"]
