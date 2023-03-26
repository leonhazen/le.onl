#!/usr/bin/env sh

ROOT_DIR=$(dirname $(readlink -f $0))
LAMBDAS_DIR="$ROOT_DIR/lambda"
DIST_DIR="$ROOT_DIR/dist"

echo "Packaging functions in $LAMBDAS_DIR..."
for func_dir in $(find $LAMBDAS_DIR -mindepth 1 -maxdepth 1 -type d); do
  func_name=$(basename $func_dir)
  zip_filename="${func_name}.zip"

  echo "Packaging $func_name..."

  rm -rf $func_dir/package
  mkdir -p $func_dir/package
  cp -r $func_dir/* $func_dir/package/
  cd $func_dir/package
  rm -rf package

  if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt -t .
  fi

  zip -r9 "$DIST_DIR/$zip_filename" .

  echo "Packaged $func_name as $zip_filename"
done

echo "All Lambda functions packaged."
