#!/bin/bash -euo pipefail
# Download Prophage-DB diamond database
wget -O prophage_db.dmnd https://prophage-db.s3.amazonaws.com/prophage_db.dmnd

# Verify download
if [ ! -f prophage_db.dmnd ]; then
    echo "Failed to download Prophage-DB"
    exit 1
fi

cat <<-END_VERSIONS > versions.yml
"PHAGE_ANALYSIS:DOWNLOAD_PROPHAGE_DB":
    wget: $(wget --version | head -n1 | grep -oP 'Wget \K[0-9.]+')
END_VERSIONS
