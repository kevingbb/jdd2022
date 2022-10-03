package com.appsdata.api.conf;

import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Order(value = Ordered.HIGHEST_PRECEDENCE)
@Component
public class RetryableDatabasePostProcessor implements BeanPostProcessor {
    private static final Logger logger = LoggerFactory.getLogger(RetryableDatabasePostProcessor.class);

    @Override
    public Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException {
        if(bean instanceof DataSource) {
            logger.info("-----> configuring a retryable datasource for beanName = {}", beanName);
            return new RetryableDataSource((DataSource) bean);
        }
        return bean;
    }

    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        return bean;
    }
}
