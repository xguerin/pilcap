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
  '((-8 transaction_time)
    (-1 match_event_indicator)))

################################################################################
# Security status class
################################################################################

(class +SecurityStatus +Layer)

(dm schema ()
  '((-8 transaction_time)
    (-6 security_group)
    (-6 asset_length)
    (-4 security_id)
    (-2 trade_date)
    (-1 match_event_indicator)
    (-1 security_trade_status)
    (-1 halt_reason)
    (-1 security_trade_event)))

(assert-size '+SecurityStatus 30)

################################################################################
# Group header class
################################################################################

(class +GroupHeader +Layer)

(dm T ("ENTRY_CLASS")
  (=: entry_class "ENTRY_CLASS"))

(dm schema ()
  '((-2 blk_len)
    (-1 num_in_group)))

(assert-size '+GroupHeader 3)

(dm parse ("LENGTH" "APP")
  (let (rem (super "LENGTH" "APP"))
    (do (: num_in_group)
      (let (nxt (new (: entry_class) (: blk_len))
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
        nxt (new '(+GroupHeader) (list (: entry_class)))
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

(class +RefreshVolume +Layer)

(dm schema ()
  '((-8 transaction_time)
    (-1 match_event_indicator)))

(assert-size '+RefreshVolume 9)

################################################################################
# Refresh book class
################################################################################

(class +RefreshBook +Layer)

(dm schema ()
  '((-8 transaction_time)
    (-1 match_event_indicator)))

(assert-size '+RefreshBook 9)

################################################################################
# Refresh trade class
################################################################################

(class +RefreshTrade +Layer)

(dm schema ()
  '((-8 transaction_time)
    (-1 match_event_indicator)))

(assert-size '+RefreshTrade 9)

################################################################################
# Refresh daily statistics entry class
################################################################################

(class +RefreshDailyStatisticsEntry +GroupEntryLayer)

(dm T ("BLK_LEN")
  (=: blk_len "BLK_LEN"))

(dm schema ()
  '((-8 entry_price NIL `(two_complement_reader 64))
    (-4 entry_size NIL `(two_complement_reader 32))
    (-4 security_id)
    (-4 rpt_seq)
    (-2 trading_ref_date)
    (-1 settle_price_type)
    (-1 update_action)
    (-1 entry_type NIL char)))

(assert-size '+RefreshDailyStatisticsEntry 25)

################################################################################
# Refresh daily statistics class
################################################################################

(class +RefreshDailyStatistics +GroupLayer)

(dm T ("BLK_LEN")
  (super "BLK_LEN" '+RefreshDailyStatisticsEntry))

(dm schema ()
  '((-8 transaction_time)
    (-1 match_event_indicator)))

(assert-size '+RefreshDailyStatistics 9)

################################################################################
# Refresh session statistics class
################################################################################

(class +RefreshSessionStatistics +Layer)

(dm schema ()
  '((-8 transaction_time)
    (-1 match_event_indicator)))

(assert-size '+RefreshSessionStatistics 9)

################################################################################
# Refresh limits banding class
################################################################################

(class +RefreshLimitsBanding +Layer)

(dm schema ()
  '((-8 transaction_time)
    (-1 match_event_indicator)))

(assert-size '+RefreshLimitsBanding 9)

################################################################################
# Refresh trade summary entry class
################################################################################

(class +RefreshTradeSummaryEntry +GroupEntryLayer)

(dm T ("BLK_LEN")
  (=: blk_len "BLK_LEN"))

(dm schema ()
  '((-8 entry_price)
    (-4 entry_size)
    (-4 security_id)
    (-4 rpt_seq)
    (-4 number_of_orders)
    (-1 aggressor_side)
    (-1 update_action)))

(assert-size '+RefreshTradeSummaryEntry 26)

################################################################################
# Refresh trade summary class
################################################################################

(class +RefreshTradeSummary +GroupLayer)

(dm T ("BLK_LEN")
  (super "BLK_LEN" '+RefreshTradeSummaryEntry))

(dm schema ()
  '((-8 transaction_time)
    (-1 match_event_indicator)))

(assert-size '+RefreshTradeSummary 9)

################################################################################
# Message header class
################################################################################

(class +MessageHeader +Layer)

(dm schema ()
  '((-2 msg_size)
    (-2 blk_len)
    (-2 template_id)
    (-2 schema_id)
    (-1 version)
    (-1 reserved)))

(assert-size '+MessageHeader 10)

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

(dm parse ("LENGTH" "APP")
  (let (rem     (super "LENGTH" "APP")
        message (get_message_type This))
    (if message
      (let (nxt (new message (: blk_len))
            len (parse nxt (- (: msg_size) 10) "APP")
            dlt (- "LENGTH" len)
            ext (- (: msg_size) dlt))
        (=: next> nxt)
        (rd ext)
        (setq rem (- len ext)))
      (let (dlt (- (: msg_size) (- "LENGTH" rem))
            len (- rem dlt))
        (rd dlt)
        (setq rem len)
        ))
    rem
    ))

################################################################################
# Packet header class
################################################################################

(class +PacketHeader +Layer)

(dm schema ()
  '((-4  seqnum)
    (-8  timestamp)))

(assert-size '+PacketHeader 12)

(dm parse ("LENGTH" "APP")
  (let (rem (super "LENGTH" "APP"))
    (while (>= rem (len '+MessageHeader))
      (let (nxt (new '(+MessageHeader))
            len (parse nxt rem "APP"))
        (=: next> (cons nxt (: next>)))
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

(de entrypoint () '(+PacketHeader))
