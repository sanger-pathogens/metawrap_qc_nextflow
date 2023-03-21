def VALIDATE_PARAMETERS() {
    // Parameter checking function
    def errors = 0

    if (params.manifest) {
        manifest=file(params.manifest)
        if (!manifest.exists()) {
            log.error("The manifest file specified does not exist.")
            errors += 1
        }
    }
    else {
        log.error("No manifest file specified. Please specify one using the --manifest option.")
        errors += 1
    }

    if (params.bmtagger_db) {
        bmtagger_db=file(params.bmtagger_db)
        if (!bmtagger_db.exists()) {
            log.error("The bmtagger database folder specified does not exist.")
            errors += 1
        }
    }

    if (!params.queue_size.toString().isNumber()) {
                log.error("The queue size is not a number, please ensure the queue size is a number.")
                errors += 1
    }

    if (errors > 0) {
            log.error(String.format("%d errors detected", errors))
            exit 1
        }
}