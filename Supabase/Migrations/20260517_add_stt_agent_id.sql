-- Add stt_agent_id column to roundtables table
-- This stores the Agora STT agent ID so we can stop it when the session ends

ALTER TABLE roundtables 
  ADD COLUMN IF NOT EXISTS stt_agent_id TEXT;
