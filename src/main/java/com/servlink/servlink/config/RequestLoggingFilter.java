package com.servlink.servlink.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.util.ContentCachingResponseWrapper;

@Component
public class RequestLoggingFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(RequestLoggingFilter.class);

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        long startMs = System.currentTimeMillis();
        ContentCachingResponseWrapper wrapped = new ContentCachingResponseWrapper(response);

        try {
            filterChain.doFilter(request, wrapped);
        } catch (Exception ex) {
            long elapsedMs = System.currentTimeMillis() - startMs;
            log.error("HTTP {} {} -> 500 ({}ms)", request.getMethod(), request.getRequestURI(), elapsedMs, ex);
            throw ex;
        } finally {
            int status = wrapped.getStatus();
            long elapsedMs = System.currentTimeMillis() - startMs;
            boolean logIt = status >= 400 || !"GET".equalsIgnoreCase(request.getMethod());
            if (logIt) {
                log.info("HTTP {} {} -> {} ({}ms)", request.getMethod(), request.getRequestURI(), status, elapsedMs);
            }
            wrapped.copyBodyToResponse();
        }
    }
}

