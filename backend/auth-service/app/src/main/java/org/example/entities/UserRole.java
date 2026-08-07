package org.example.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.Column;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "roles")
public class UserRole {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO) //Auto - Increment
    @Column(name = "role_id") // SQL col name will be this
    private Long roleId;
    
    private String name;

}
