# Use Alpine as the base image
FROM alpine:latest

# Install cifs-utils for SMB operations
RUN apk update && \
    apk add --no-cache cifs-utils

# Create the entrypoint script
RUN echo '#!/bin/sh\n\
if [ "$#" -lt 5 ]; then\n\
  echo "Usage: $0 <server> <share> <mount_point> <username> <password> [<options>]"\n\
  exit 1\n\
fi\n\
SERVER="$1"\n\
SHARE="$2"\n\
MOUNT_POINT="$3"\n\
USERNAME="$4"\n\
PASSWORD="$5"\n\
shift 5\n\
OPTIONS="$@"\n\
mount -t cifs "//$SERVER/$SHARE" "$MOUNT_POINT" -o username=$USERNAME,password=$PASSWORD,$OPTIONS\n' > /usr/local/bin/mount-smb.sh && \
    chmod +x /usr/local/bin/mount-smb.sh

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/mount-smb.sh"]
