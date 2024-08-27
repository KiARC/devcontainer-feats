#!/bin/bash

set -e
source dev-container-features-test-lib
check "check zig version" bash -c "zig version | grep '0.12.0'"
reportResults