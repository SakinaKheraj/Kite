package org.example.entities;

import java.util.HashSet;
import java.util.Set;

import jakarta.persistence.Column;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "users")
public class UserInfo {
    @Id
    @Column(name = "user_id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long userId;
    
    private String username;

    private String password;

    // Many to many relationship
    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "user_roles", // join table name
        joinColumns = @JoinColumn(name = "user_id"), // which col to join and
        inverseJoinColumns = @JoinColumn(name = "role_id") // with whom
    )

    private Set<UserRole> roles = new HashSet<>(); // result after join is stored

}
