package com.appsdata.api.conf;

import org.springframework.jdbc.datasource.AbstractDataSource;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.Retryable;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RetryableDataSource extends AbstractDataSource {
    private static final Logger logger = LoggerFactory.getLogger(RetryableDataSource.class);

    private final DataSource dataSource;

    public RetryableDataSource(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    @Retryable(maxAttempts = 3, backoff = @Backoff(multiplier = 1.5, maxDelay = 5000))
    public Connection getConnection() throws SQLException {
        logger.info("getting connection ...");
        return dataSource.getConnection();
    }

    @Override
    @Retryable(maxAttempts = 3, backoff = @Backoff(multiplier = 1.5, maxDelay = 5000))
    public Connection getConnection(String username, String password) throws SQLException {
        logger.info("getting connection by username and password ...");
        return dataSource.getConnection(username, password);
    }
}
