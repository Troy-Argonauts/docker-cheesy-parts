FROM debian:stretch

SHELL ["/bin/bash", "--login", "-c"]

RUN apt-get update && \
    # Clone cheesy-parts
    apt-get install -y --no-install-recommends ca-certificates git && \
    git clone --depth 1 https://github.com/Team254/cheesy-parts.git && \
    cd cheesy-parts && \
    # Install Ruby
    apt-get install -y --no-install-recommends libssl1.0-dev rbenv ruby-all-dev ruby-build && \
    rbenv install $(rbenv install --list | awk '{print $1}' | grep ^$(cat .rbenv-version .ruby-version 2> /dev/null || true) | tail -1) && \
    gem install bundler && \
    # Install cheesy-parts
    apt-get install -y --no-install-recommends default-libmysqlclient-dev jq moreutils && \
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
