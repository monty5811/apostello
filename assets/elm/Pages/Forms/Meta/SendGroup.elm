module Pages.Forms.Meta.SendGroup exposing (meta)

import Forms.Model exposing (FieldMeta)


meta : { content : FieldMeta, recipient_group : FieldMeta, scheduled_time : FieldMeta }
meta =
    { content = FieldMeta True "id_content" "content" "Content" Nothing
    , recipient_group = FieldMeta True "id_recipient_group" "recipient_group" "Recipient Group" Nothing
    , scheduled_time = FieldMeta False "id_scheduled_time" "scheduled_time" "Scheduled Time" (Just "Leave this blank to send your message immediately, otherwise select a date and time to schedule your message")
    }
