package com.bodimTikka.bodimTikka.controller;

import com.bodimTikka.bodimTikka.DTO.PaymentRequestDTO;
import com.bodimTikka.bodimTikka.DTO.PaymentResponseDTO;
import com.bodimTikka.bodimTikka.model.Payment;
import com.bodimTikka.bodimTikka.service.PaymentService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/payments")
public class PaymentController {

    private final PaymentService paymentService;

    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    // TODO: make get mapping for payment
    @PostMapping("/create")
    public ResponseEntity<PaymentResponseDTO> createPayment(@Valid @RequestBody PaymentRequestDTO paymentRequest, UriComponentsBuilder ucb) {
        Payment payment = paymentService.createPayment(paymentRequest);
        URI locationOfNewPayment = ucb.path("/payments/{id}").
                buildAndExpand(payment.getPaymentId()).toUri();
        return ResponseEntity.created(locationOfNewPayment).build();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Payment> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(paymentService.getById(id));
    }

    @GetMapping
    public ResponseEntity<List<PaymentResponseDTO>> getAllPayments() {
        return ResponseEntity.ok(paymentService.getAllPayments());
    }

    @GetMapping("/room/{id}")
    public ResponseEntity<List<Payment>> getPaymentByRoomId(
            @PathVariable Long id,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(paymentService.getPaymentByRoomId(id, limit, page));
    }

}
