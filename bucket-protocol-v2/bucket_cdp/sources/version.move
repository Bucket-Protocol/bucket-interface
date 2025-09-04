module bucket_v2_cdp::version;

use bucket_v2_usd::usdb::{Treasury};
use bucket_v2_cdp::witness::{BucketV2CDP};

/// Constants

const PACKAGE_VERSION: u16 = 1;

/// Public Funs

public fun package_version(): u16 { PACKAGE_VERSION }

public(package) fun assert_valid_package(treasury: &Treasury) {
    abort 0;
}
