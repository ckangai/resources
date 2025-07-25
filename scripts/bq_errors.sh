# BigQuery error

# --- BigQuery Errors Simulation ---
if bq --project_id="${PROJECT_ID}" mk --schema=product_id:integer,product_name:string,supplier_id:integer,category_id:integer,quantity_per_unit:string,unit_price:float,units_in_stock:integer,units_on_order:integer,reorder_level:integer,discontinued:boolean --table "$1:demos.products" 2>&1 | logger -t "bq-table-creation"; then
  echo "Successfully created BigQuery table ${PROJECT_ID}:demos.products." | logger -t "bq-table-creation"
else
  echo "ERROR: Failed to create BigQuery table ${PROJECT_ID}:demos.products. Check logs for details." | logger -t "bq-table-creation"
fi

bq --project_id="${PROJECT_ID}" query \
   --use_legacy_sql=false \
   --format=prettyjson \
   "SELECT * FROM demos.products"

bq --project_id="${PROJECT_ID}" query \
   --use_legacy_sql=false \
   --format=prettyjson \
   "SELECT 1/0"


bq mk --dataset ${PROJECT_ID}:demos

bq --project_id ${PROJECT_ID} load --source_format=CSV \
--autodetect \
demos.customers \
gs://${PROJECT_ID}/customers.csv