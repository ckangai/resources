-- Step 1: Create the product reviews table
CREATE OR REPLACE TABLE `demo_dataset.product_reviews` (
  review_id INT64,
  product_name STRING,
  review_text STRING,
  submission_date DATE
);

-- Step 2: Insert realistic sample data for sentiment classification
INSERT INTO `demo_dataset.product_reviews` (review_id, product_name, review_text, submission_date)
VALUES
  (1, 'CloudSync Pro', 'Absolute lifesaver! The real-time sync works flawlessly across all my devices and saving hours of manual backups every single week.', CURRENT_DATE()),
  (2, 'DataForge Enterprise', 'Extremely disappointed. The UI is sluggish, the documentation is completely outdated, and it crashes every time I try to import a CSV file larger than 10MB.', CURRENT_DATE()),
  (3, 'AppScale Engine', 'It gets the job done for basic deployment pipelines, but the pricing tier climbs way too fast for small startups. It is average at best.', CURRENT_DATE());