package com.bodimTikka.bodimTikka.model;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;

@Entity
@Table(name = "payment_log")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PaymentRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "from_user_id", nullable = false, foreignKey = @ForeignKey(name = "fk_paymentrecord_from_user"))
    private User fromUser;

    @ManyToOne
    @JoinColumn(name = "to_user_id", nullable = false, foreignKey = @ForeignKey(name = "fk_paymentrecord_to_user"))
    private User toUser;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal amount;

    @ManyToOne
    @JoinColumn(name = "payment_id", nullable = false, foreignKey = @ForeignKey(name = "fk_paymentrecord_payment"))
    private Payment payment;
}
