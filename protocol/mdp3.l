(symbols 'mdp3 'netstack)

################################################################################
# Utilities
################################################################################

(de two_complement_reader (@BITS "VALUE")
  (curry (@BITS) ("VALUE")
    (cond
      ((= "VALUE" (- (** 2 (- @BITS 1)) 1)) 0)
      ((> "VALUE" (- (** 2 (- @BITS 1)) 1)) (- "VALUE" (** 2 @BITS)))
      (T "VALUE")
      )))

################################################################################
# Channel reset class
################################################################################

(class +ChannelReset +Layer)

(dm schema ()
  '((transaction_time       -8)
    (match_event_indicator  -1)
    ))

################################################################################
# Security status class
################################################################################

(class +SecurityStatus +Layer)

(dm schema ()
  '((transaction_time       -8)
    (security_group         -6)
    (asset_length           -6)
    (security_id            -4)
    (trade_date             -2)
    (match_event_indicator  -1)
    (security_trade_status  -1)
    (halt_reason            -1)
    (security_trade_event   -1)
    ))

(assert-size '+SecurityStatus 30)

################################################################################
# Group header class
################################################################################

(class +Group +Layer)

(dm T ("ENTRY_CLASS")
  (=: entry_class "ENTRY_CLASS"))

(dm schema ()
  '((blk_len      -2)
    (num_in_group -1)
    ))

(assert-size '+Group 3)

(dm parse ("LENGTH" "APP")
  (let (rem (super "LENGTH" "APP"))
    (when (: entry_class)
      (do (: num_in_group)
        (let (nxt (new (: entry_class) (: blk_len))
                  len (parse nxt rem "APP"))
          (=: next> (append (: next>) (list nxt)))
          (setq rem len)
          )))
    (rd rem)
    0
    ))

(dm foldl ("FUN" "ACC")
  (let (acc  ("FUN" "ACC" This)
        insp '((acc elm)
               (conc acc (foldl elm "FUN" NIL))
               ))
    (lang~foldl insp acc (: next>))
    ))

(dm foldr ("FUN" "ACC")
  (let (insp  '((elm acc)
                (cons (foldr elm "FUN" NIL) acc))
        acc   (lang~foldr insp (: next>) "ACC"))
    ("FUN" This acc)
    ))

################################################################################
# Group layer class
################################################################################

(class +GroupLayer +Layer)

(dm T ("BLK_LEN" "ENTRY_CLASS")
  (=: blk_len "BLK_LEN")
  (=: entry_class "ENTRY_CLASS"))

(dm parse ("LENGTH" "APP")
  (super "LENGTH" "APP")
  (rd (- (: blk_len) (len This)))
  (let (rem (- "LENGTH" (: blk_len))
        typ (if (: entry_class) (list (: entry_class)) NIL)
        nxt (new '(+Group) typ)
        len (parse nxt rem "APP"))
    (=: next> nxt)
    len
    ))

################################################################################
# Group entry layer class
################################################################################

(class +GroupEntryLayer +Layer)

(dm T ("BLK_LEN")
  (=: blk_len "BLK_LEN"))

(dm parse ("LENGTH" "APP")
  (let (rem (super "LENGTH" "APP")
        dlt (- "LENGTH" rem)
        ext (- (: blk_len) dlt))
    (rd ext)
    (- rem ext)
    ))

################################################################################
# Refresh volume class
################################################################################

(class +RefreshVolume +GroupLayer)

(dm schema ()
  '((transaction_time       -8)
    (match_event_indicator  -1)
    ))

(assert-size '+RefreshVolume 9)

################################################################################
# Refresh book class
################################################################################

(class +RefreshBook +GroupLayer)

(dm schema ()
  '((transaction_time       -8)
    (match_event_indicator  -1)
    ))

(assert-size '+RefreshBook 9)

################################################################################
# Refresh trade class
################################################################################

(class +RefreshTrade +GroupLayer)

(dm schema ()
  '((transaction_time       -8)
    (match_event_indicator  -1)
    ))

(assert-size '+RefreshTrade 9)

################################################################################
# Refresh daily statistics entry class
################################################################################

(class +RefreshDailyStatisticsEntry +GroupEntryLayer)

(dm T ("BLK_LEN")
  (=: blk_len "BLK_LEN"))

(dm schema ()
  '((entry_price        -8 NIL `(two_complement_reader 64))
    (entry_size         -4 NIL `(two_complement_reader 32))
    (security_id        -4)
    (rpt_seq            -4)
    (trading_ref_date   -2)
    (settle_price_type  -1)
    (update_action      -1)
    (entry_type         -1 NIL char)))

(assert-size '+RefreshDailyStatisticsEntry 25)

################################################################################
# Refresh daily statistics class
################################################################################

(class +RefreshDailyStatistics +GroupLayer)

(dm T ("BLK_LEN")
  (super "BLK_LEN" '+RefreshDailyStatisticsEntry))

(dm schema ()
  '((transaction_time       -8)
    (match_event_indicator  -1)
    ))

(assert-size '+RefreshDailyStatistics 9)

################################################################################
# Refresh session statistics class
################################################################################

(class +RefreshSessionStatistics +GroupLayer)

(dm schema ()
  '((transaction_time       -8)
    (match_event_indicator  -1)
    ))

(assert-size '+RefreshSessionStatistics 9)

################################################################################
# Refresh limits banding class
################################################################################

(class +RefreshLimitsBanding +GroupLayer)

(dm schema ()
  '((transaction_time       -8)
    (match_event_indicator  -1)
    ))

(assert-size '+RefreshLimitsBanding 9)

################################################################################
# Refresh trade summary entry class
################################################################################

(class +RefreshTradeSummaryEntry +GroupEntryLayer)

(dm T ("BLK_LEN")
  (=: blk_len "BLK_LEN"))

(dm schema ()
  '((entry_price      -8)
    (entry_size       -4)
    (security_id      -4)
    (rpt_seq          -4)
    (number_of_orders -4)
    (aggressor_side   -1)
    (update_action    -1)
    ))

(assert-size '+RefreshTradeSummaryEntry 26)

################################################################################
# Refresh trade summary class
################################################################################

(class +RefreshTradeSummary +GroupLayer)

(dm T ("BLK_LEN")
  (super "BLK_LEN" '+RefreshTradeSummaryEntry))

(dm schema ()
  '((transaction_time       -8)
    (match_event_indicator  -1)
    ))

(assert-size '+RefreshTradeSummary 9)

################################################################################
# Message header class
################################################################################

(class +Message +Layer)

(dm schema ()
  '((msg_size     -2)
    (blk_len      -2)
    (template_id  -2)
    (schema_id    -2)
    (version      -1)
    (reserved     -1)
    ))

(assert-size '+Message 10)

(dm get_message_type ()
  (case (: template_id)
    (4  '(+ChannelReset))
    (30 '(+SecurityStatus))
    (32 '(+RefreshBook))
    (33 '(+RefreshDailyStatistics))
    (34 '(+RefreshLimitsBanding))
    (35 '(+RefreshSessionStatistics))
    (36 '(+RefreshTrade))
    (37 '(+RefreshVolume))
    (42 '(+RefreshTradeSummary))
    (T  NIL)
    ))

#
# "LENGTH" here is the length of the data in the full frame
#
(dm parse ("LENGTH" "APP")
  (let (rem     (super "LENGTH" "APP")
        dln     (- (: msg_size) (len This))
        message (get_message_type This))
    (if message
      (let (nxt (new message (: blk_len))
            len (parse nxt dln "APP"))
        (=: next> nxt)
        (rd len)
        (setq rem (- rem dln)))
      (prog
        (rd dln)
        (setq rem (- rem dln))
        ))
    rem
    ))

################################################################################
# Packet header class
################################################################################

(class +MDP3 +Layer)

(dm schema ()
  '((seqnum     -4)
    (timestamp  -8)
    ))

(assert-size '+MDP3 12)

(dm parse ("LENGTH" "APP")
  (let (rem (super "LENGTH" "APP"))
    (while (>= rem (len '+Message))
      (let (nxt (new '(+Message))
            len (parse nxt rem "APP"))
        (=: next> (append (: next>) (list nxt)))
        (setq rem len)
        ))
    (rd rem)
    0
  ))

(dm foldl ("FUN" "ACC")
  (let (acc  ("FUN" "ACC" This)
        insp '((acc elm)
               (conc acc (foldl elm "FUN" NIL))
               ))
    (lang~foldl insp acc (: next>))
    ))

(dm foldr ("FUN" "ACC")
  (let (insp  '((acc elm)
                (cons (foldr elm "FUN" NIL) acc))
        acc   (lang~foldl insp "ACC" (: next>)))
    ("FUN" This acc)
    ))

################################################################################
# Entry point
################################################################################

(de entrypoint () '(+MDP3))
