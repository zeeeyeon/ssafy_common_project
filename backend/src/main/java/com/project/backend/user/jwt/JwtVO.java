package com.project.backend.user.jwt;


/*
 * SECRET 노출되면 안된다. (클라우드AWS - 환경변수, 파일에 있는 것을 읽을 수도 있고!!
 * 리플래시 토큰 (X)
 */

    public interface JwtVO {
        public static final String SECRET = "7Iqk7YyM66W07YOA7L2U65Sp7YG065+9U3ByaW5n6rCV7J2Y7Yqc7YSw7LWc7JuQ67mI7J6F64uI64ukLg=="; // HS256 (대칭키)
        public static final int EXPIRATION_TIME = 1000 * 60 * 60 * 24 * 7; // 일주일
        public static final String TOKEN_PREFIX = "Bearer ";
        public static final String HEADER = "Authorization";
    }
