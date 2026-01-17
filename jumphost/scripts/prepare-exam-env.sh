#!/bin/bash
exec >> /proc/1/fd/1 2>&1


# Log function with timestamp
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Set defaults (facilitator calls: prepare-exam-env <nodeCount> <examId>)
EXAM_ID=${2:-""}

echo "Exam ID: $EXAM_ID"

#check docker is running
if ! docker info > /dev/null 2>&1; then
  log "Docker is not running"
  log "Attempting to start docker"
  dockerd &
  sleep 2
  #check docker is running 3 times with 2 second interval
  for i in {1..3}; do
    if docker info > /dev/null 2>&1; then
      log "Docker started successfully"
      break
    fi
    log "Docker failed to start, retrying..."
    sleep 2
  done
fi

log "Starting exam environment preparation"

#Pull assets from URL
curl facilitator:3000/api/v1/exams/$EXAM_ID/assets -o assets.tar.gz

mkdir -p /tmp/exam-assets
#Unzip assets
tar -xzvf assets.tar.gz -C /tmp/exam-assets    

#Remove assets.tar.gz
rm assets.tar.gz

#make every file in /tmp/exam-assets executable
find /tmp/exam-assets -type f -exec chmod +x {} \;

echo "Exam assets downloaded and prepared successfully" 

sleep 1

#Run fast setup for speed optimization
log "Running FAST exam setup..."
if [ -f "/tmp/exam-assets/scripts/setup/fast_setup.sh" ]; then
  bash "/tmp/exam-assets/scripts/setup/fast_setup.sh"
else
  # Fallback to comprehensive setup if fast setup not available
  log "Fast setup not found, using comprehensive setup..."
  if [ -f "/tmp/exam-assets/scripts/setup/comprehensive_setup.sh" ]; then
    bash "/tmp/exam-assets/scripts/setup/comprehensive_setup.sh"
  fi
fi

#Run individual setup scripts in parallel for faster execution
log "Running individual setup scripts in parallel..."
for script in /tmp/exam-assets/scripts/setup/q*_setup.sh; do 
  if [ -f "$script" ]; then
    bash "$script" &
  fi
done

# Wait for all background jobs to complete
wait
log "All setup scripts completed"

log "Exam environment preparation completed successfully"
exit 0 