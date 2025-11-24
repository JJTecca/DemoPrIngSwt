package com.internshipapp.common;

import java.time.LocalDateTime;
/******************************
 *Purpose of DTO Pattern:
 * 1.Data Transfer: Moves data between layers (Database → Business Logic → UI)
 * 2. Decoupling: Separates database entities from API/UI models
 * 3. Security: Controls what data gets exposed (avoid exposing sensitive fields)
 * 4. Customization: Combine data from multiple entities into one object
 * NOTE: Not all fields need to be used
 *****************************/
public class SessDto {
    private Long id;
    private Long userId;
    private String username;
    private LocalDateTime login;
    private String token;

    /************************************************
     *        Constructors
     *  - we have more type of constructors
     *  - adjust params as needed
     *  - *NOTE* : constructors called based on feature */
    /****************************************************************
     *               PERFORMANCE NOTES
     *  - Lazy relationships should not be initialized in constructors
     *   - Consider using factory methods for complex object creation
     **************************************************************/
    public SessDto() {}
    public SessDto(Long id, Long userId, String username, LocalDateTime login, String token) {
        this.id = id;
        this.userId = userId;
        this.username = username;
        this.login = login;
        this.token = token;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public LocalDateTime getLogin() { return login; }
    public void setLogin(LocalDateTime login) { this.login = login; }
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
}