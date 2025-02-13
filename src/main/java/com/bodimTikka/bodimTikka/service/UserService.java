package com.bodimTikka.bodimTikka.service;

import com.bodimTikka.bodimTikka.model.User;
import com.bodimTikka.bodimTikka.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.bodimTikka.bodimTikka.DTO.UserProjection;

import java.util.List;
import java.util.Optional;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }

    public Optional<User> getUserByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public User createUser(User user) {
        return userRepository.save(user);
    }

    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }

    public boolean existsById(Long userId){
        return userRepository.existsById(userId);
    }

    public Optional<UserProjection> findUserProjectionByEmail(String email) {
        return userRepository.findUserProjectionByEmail(email);
    }
}
