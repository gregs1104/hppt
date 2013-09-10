SELECT
    client_addr,
    sent_xlog,sent_offset,replay_xlog,replay_offset,
    sent_offset - (
        replay_offset - (sent_xlog - replay_xlog) * 255 * 16 ^ 6 ) AS replay_byte_lag
FROM (
    SELECT
        client_addr,
        ('x' || split_part(sent_location, '/', 1))::text::bit(64)::int8 AS sent_xlog,
        ('x' || split_part(replay_location, '/', 1))::text::bit(64)::int8 AS replay_xlog,
        ('x' || split_part(sent_location, '/', 2))::text::bit(64)::int8 AS sent_offset,
        ('x' || split_part(replay_location, '/', 2))::text::bit(64)::int8 AS replay_offset
    FROM pg_stat_replication
) AS s;

