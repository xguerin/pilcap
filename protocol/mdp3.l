(symbols 'mdp3 'netstack)

################################################################################
# Utilities
################################################################################

(de fpformat (value)
    (format value 7))

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
  '((-2 blk_len       NIL format)
    (-1 num_in_group  NIL format)))

(assert-size '+GroupHeader 3)

(dm foldl ("CB" "APP" "ACC")
  (let (nxt ("CB" This (cadr "ACC"))
        sze (- (car "ACC") (len This))
        nac (list sze nxt))
    (do (: num_in_group)
      (setq nac (foldl (parse (new (: entry_class) (: blk_len))) "CB" "APP" nac)))
    nac
    ))

(dm foldr ("CB" "APP" "ACC")
  (let ((ilen idat) "ACC"
        tmp         "ACC"
        rls         NIL)
    (do (: num_in_group)
      (let ((len res) (foldr (parse (new (: entry_class) (: blk_len))) "CB" "APP" tmp))
        (setq tmp (list len idat))
        (setq rls (conc rls (list (cdar res))))
        ))
    (let (nxt ("CB" This (list (cons "entries" (cons T rls))))
          sze (- (car tmp) (len This)))
      (list sze nxt)
      )))

################################################################################
# Group layer class
################################################################################

(class +GroupLayer +Layer)

(dm T ("BLK_LEN" "ENTRY_CLASS")
  (=: blk_len "BLK_LEN")
  (=: entry_class "ENTRY_CLASS"))

(dm len ()
  (: blk_len))

(dm parse ()
  (let (schema_len (lang~foldl '((acc e) (+ acc (abs (car e)))) 0 (schema This)))
    (super)
    (rd (- (: blk_len) schema_len)))
  This)

(dm foldl ("CB" "APP" "ACC")
  (let (nxt ("CB" This (cadr "ACC"))
        sze (- (car "ACC") (len This))
        nac (list sze nxt))
    (foldl (parse (new '(+GroupHeader) (list (: entry_class)))) "CB" "APP" nac)
    ))

(dm foldr ("CB" "APP" "ACC")
  (let (message     (parse (new '(+GroupHeader) (list (: entry_class))))
        (rlen rdat) (foldr message "CB" "APP" "ACC")
        nxt         ("CB" This rdat)
        sze         (- rlen (len This)))
    (list sze nxt)
    ))

################################################################################
# Group entry layer class
################################################################################

(class +GroupEntryLayer +Layer)

(dm T ("BLK_LEN")
  (=: blk_len "BLK_LEN"))

(dm len ()
  (: blk_len))

(dm parse ()
  (let (schema_len (lang~foldl '((acc e) (+ acc (abs (car e)))) 0 (schema This)))
    (super)
    (rd (- (: blk_len) schema_len)))
  This)

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

(class +RefreshDailyStatisticsEntry +Layer)

(dm T ("BLK_LEN")
  (=: blk_len "BLK_LEN"))

(dm schema ()
  '((-8 entry_price)
    (-4 entry_size)
    (-4 security_id       NIL format)
    (-4 rpt_seq           NIL format)
    (-2 trading_ref_date  NIL format)
    (-1 settle_price_type NIL format)
    (-1 update_action     NIL format)
    (-1 entry_type        NIL format)))

(assert-size '+RefreshDailyStatisticsEntry 25)

(dm len ()
  (: blk_len))

(dm parse ()
  (super)
  (rd (- (: blk_len) 25))
  This)

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
    (-4 security_id       NIL format)
    (-4 rpt_seq           NIL format)
    (-4 number_of_orders  NIL format)
    (-1 aggressor_side    NIL format)
    (-1 update_action     NIL format)))

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
  '((-2 msg_size    NIL format)
    (-2 blk_len     NIL format)
    (-2 template_id NIL format)
    (-2 schema_id   NIL format)
    (-1 version     NIL format)
    (-1 reserved)))

(assert-size '+MessageHeader 10)

(dm msg_size ()
  (: msg_size))

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

(dm foldl ("CB" "APP" "ACC")
  (let (nxt     ("CB" This (cadr "ACC"))
        sze     (- (car "ACC") (len This))
        nac     (list sze nxt)
        message (get_message_type This))
    (if message
      (foldl (parse (new message (: blk_len))) "CB" "APP" nac)
      nac)
    ))

(dm foldr ("CB" "APP" "ACC")
  (let (message     (get_message_type This)
        (rlen rdat) (if message
                      (foldr (parse (new message (: blk_len))) "CB" "APP" "ACC")
                    "   ACC")
        nxt ("CB" This rdat)
        sze (- rlen (len This)))
    (list sze nxt)
    ))

################################################################################
# Packet header class
################################################################################

(class +PacketHeader +Layer)

(dm schema ()
  '((-4  seqnum    NIL format)
    (-8  timestamp NIL format)))

(assert-size '+PacketHeader 12)

(dm foldl ("CB" "APP" "ACC")
  (let (nxt ("CB" This (cadr "ACC"))
        sze (- (car "ACC") (len This))
        nac (list sze nxt))
    (while (> (car nac) 10)
      (let (message   (parse (new '(+MessageHeader)))
            (len res) (foldl message "CB" "APP" nac)
            delta     (- sze len)
            rem       (- (msg_size message) delta))
        (setq sze (- len rem))
        (setq nac (list sze res))
        (rd rem)
        ))
    nac
    ))

(dm foldr ("CB" "APP" "ACC")
  (let ((ilen idat) "ACC"
        tmp         "ACC"
        rls         NIL)
    (while (> (car tmp) 10)
      (let (message     (parse (new '(+MessageHeader)))
            (rlen rdat) (foldr message "CB" "APP" tmp)
            delta       (- sze rlen)
            rem         (- (msg_size message) delta))
        (setq tmp (list (- rlen rem) idat))
        (setq rls (conc rls (list (cdar rdat))))
        (rd rem)
        ))
    (let (nxt ("CB" This (list (cons "messages" (cons T rls))))
          sze (- (car tmp) (len This)))
      (list sze nxt)
      )))

################################################################################
# Entry point
################################################################################

(de entrypoint () '(+PacketHeader))
