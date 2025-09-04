module bucket_v2_flash::version {

    /// Constants

    const PACKAGE_VERSION: u16 = 1;

    /// Public Funs

    public fun package_version(): u16 { PACKAGE_VERSION }
}
