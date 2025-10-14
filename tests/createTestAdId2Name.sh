echo 'ad_Id,ad_Name' > ad-id2name.csv; for i in {0..2}; do for j in {0..9};do echo ad000000$i$j,ad-$i$j-name >> ad-id2name.csv;done ;done
