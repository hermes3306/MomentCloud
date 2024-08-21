for file in upload/*; do
    new_name=$(echo "$file" | sed -e 's/ /_/g' -e 's/["'\'']//g')
    mv "$file" "$new_name"
done

