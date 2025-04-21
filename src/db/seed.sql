-- Insert initial meditation sessions
INSERT INTO meditation_sessions (id, name, duration, description, category, attribution, popular, play_count)
VALUES
  (
    uuid_generate_v4(),
    'Three Minute Breathing',
    3.5,
    'A short mindfulness exercise focusing on bringing awareness to the process of breathing.',
    'breathing',
    'Peter Morgan, freemindfulness.org',
    true,
    542
  ),
  (
    uuid_generate_v4(),
    'Five Minute Breathing (MARC)',
    5,
    'A brief mindfulness practice to cultivate awareness of breathing, from UCLA''s Mindful Awareness Research Center.',
    'breathing',
    'Mindful Awareness Research Centre, UCLA',
    true,
    753
  ),
  (
    uuid_generate_v4(),
    'Life Happens (5 Minutes)',
    5,
    'A guided meditation focusing on embracing life''s challenges through mindful breathing.',
    'breathing',
    'Mindfulness Meditation',
    false,
    123
  ),
  (
    uuid_generate_v4(),
    'Breath Awareness (6 Minutes)',
    6,
    'Develop breath awareness and mindful presence through this short guided practice.',
    'breathing',
    'Still Mind',
    false,
    210
  ),
  (
    uuid_generate_v4(),
    'Ten Minute Breathing',
    10,
    'A guided breathing meditation to help establish a deeper awareness of the present moment.',
    'breathing',
    'Peter Morgan, freemindfulness.org',
    true,
    421
  ),
  (
    uuid_generate_v4(),
    'Mindfulness of Breathing (10 Minutes)',
    10,
    'A gentle practice to develop concentration and awareness through mindful breathing.',
    'breathing',
    'Padraig O''Morain',
    false,
    331
  ),
  (
    uuid_generate_v4(),
    'Sleep Meditation',
    15,
    'A calming meditation designed to help you fall asleep more easily and improve sleep quality.',
    'sleep',
    'Meditation App',
    true,
    823
  ),
  (
    uuid_generate_v4(),
    'Body Scan Relaxation',
    12,
    'A guided meditation that systematically focuses on different parts of the body to release tension and promote relaxation.',
    'body',
    'Meditation App',
    true,
    512
  ),
  (
    uuid_generate_v4(),
    'Loving-Kindness Practice',
    8,
    'A meditation to cultivate feelings of compassion and loving-kindness toward yourself and others.',
    'compassion',
    'Meditation App',
    false,
    287
  ),
  (
    uuid_generate_v4(),
    'Stress Relief Meditation',
    10,
    'A guided practice designed to reduce stress and promote a sense of calm and balance.',
    'relaxation',
    'Meditation App',
    true,
    642
  ),
  (
    uuid_generate_v4(),
    'Morning Mindfulness',
    5,
    'A short morning meditation to start your day with clarity and presence.',
    'guided',
    'Meditation App',
    false,
    218
  ),
  (
    uuid_generate_v4(),
    'Silent Meditation Timer',
    20,
    'A timer for unguided meditation with gentle bells at the beginning and end.',
    'unguided',
    'Meditation App',
    false,
    175
  ); 