  ####  Input: token file (one review per line; tokens are delimited by white space) 
  ####         label file (one label per line)
  ####  These input files were generated by prep_imdb.sh and included in the package. 
  ####  To find the order of the data points, see prep_imdb.sh and the files at lst/. 

  gpu=0  # <= change this to, e.g., "gpu=0" to use a specific GPU. 
  mem=4   # pre-allocate 4GB device memory 
  gpumem=${gpu}:${mem}


  prep_exe=../bin/prepText
  cnn_exe=../bin/conText

  #---  Step 1. Generate vocabulary for NB weights
  echo Generaing uni-, bi-, and tri-gram vocabulary from training data to make NB-weights ... 

  options="LowerCase UTF8"

  voc12=data/imdb_trn-12gram.vocab
  rm -f $voc12
  for nn in 1 2; do
    vocab_fn=data/imdb_trn-${nn}gram.vocab  
    $prep_exe gen_vocab input_fn=data/imdb-train.txt.tok vocab_fn=$vocab_fn \
                              $options WriteCount n=$nn
    cat $vocab_fn >> $voc12
  done 

  #--- Step 1.2, Generate 3,4-gram for NB weights (Chang)
  voc34=data/imdb_trn-34gram.vocab
  rm -f $voc34
  for nn in 3 4; do
    vocab_fn=data/imdb_trn-${nn}gram.vocab  
    $prep_exe gen_vocab input_fn=data/imdb-train.txt.tok vocab_fn=$vocab_fn \
                              $options WriteCount n=$nn
    cat $vocab_fn >> $voc34
  done 
  #--- Step 1.2, ends

  #---  Step 2-1. Generate NB-weights 
  echo Generating NB-weights ... 
  $prep_exe gen_nbw \
       vocab_fn=$voc12 \
       train_fn=data/imdb-train \
       $options text_fn_ext=.txt.tok label_fn_ext=.cat \
       label_dic_fn=data/imdb_cat.dic \
       nbw_fn=data/imdb.nbw3.dmat

  #---  Step 2-1-2. Generate NB-weights for 3,4-gram (Chang)
  echo Generating NB-weights ... 
  $prep_exe gen_nbw \
       vocab_fn=$voc34 \
       train_fn=data/imdb-train \
       $options text_fn_ext=.txt.tok label_fn_ext=.cat \
       label_dic_fn=data/imdb_cat.dic \
       nbw_fn=data/imdb.nbw6.dmat
  #--- add ends


  #---  Step 2-2.  Generate NB-weighted bag-of-ngram files ...
  echo 
  echo Generating NB-weighted bag-of-ngram files ... 
  for set in train test; do
    $prep_exe gen_nbwfeat \
       vocab_fn=$voc12 \
       input_fn=data/imdb-${set} \
       output_fn_stem=data/imdb_${set}-nbw3 \
       x_ext=.xsmatvar \
       $options text_fn_ext=.txt.tok label_fn_ext=.cat \
       label_dic_fn=data/imdb_cat.dic \
       nbw_fn=data/imdb.nbw3.dmat
  done

  #---  Step 2-2.  Generate NB-weighted bag-of-ngram files for 3,4(Chang) ...
  echo 
  echo Generating NB-weighted bag-of-ngram files ... 
  for set in train test; do
    $prep_exe gen_nbwfeat \
       vocab_fn=$voc34 \
       input_fn=data/imdb-${set} \
       output_fn_stem=data/imdb_${set}-nbw6 \
       x_ext=.xsmatvar \
       $options text_fn_ext=.txt.tok label_fn_ext=.cat \
       label_dic_fn=data/imdb_cat.dic \
       nbw_fn=data/imdb.nbw6.dmat
  done
  #--- add ends


  #---  Step 3.  Generate vocabulty for CNN 
  echo 
  echo Generating vocabulary from training data for CNN ... 
  max_num=30000
  vocab_fn=data/imdb_trn-1gram.${max_num}.vocab  
  $prep_exe gen_vocab input_fn=data/imdb-train.txt.tok vocab_fn=$vocab_fn max_vocab_size=$max_num \
                            $options WriteCount

  #---  Step 4. Generate region files (data/*.xsmatvar) and target files (data/*.y) for training and testing CNN.  
  #     We generate region vectors of the convolution layer and write them to a file, instead of making them 
  #     on the fly during training/testing. 
  echo 
  echo Generating region files ...
  for pch_sz in 2 3; do
    for set in train test; do 
      rnm=data/imdb_${set}-p${pch_sz}
     $prep_exe gen_regions \
       region_fn_stem=$rnm input_fn=data/imdb-${set} vocab_fn=$vocab_fn \
       $options text_fn_ext=.txt.tok label_fn_ext=.cat \
       label_dic_fn=data/imdb_cat.dic \
       patch_size=$pch_sz patch_stride=1 padding=$((pch_sz-1))
    done
  done

  #---  Step 5. Training and test using GPU
  log_fn=log_output/imdb-seq2-bown.log
  perf_fn=perf/imdb-seq2-bown-perf.csv
  echo 
  echo Training CNN and testing ... 
  echo This takes a while.  See $log_fn and $perf_fn for progress and see param/seq2-bown.param for the rest of the parameters. 
  nodes0=20; nodes1=1000; nodes2=1000; nodes3=20 # number of neurons (weight vectors) in the convolution layers 
  $cnn_exe $gpumem cnn \
         0nodes=$nodes0 0resnorm_width=$nodes0 1nodes=$nodes1 1resnorm_width=$nodes1 2nodes=$nodes2 2resnorm_width=$nodes2 3nodes=$nodes3 3resnorm_width=$nodes3 \
         data_dir=data trnname=imdb_train- tstname=imdb_test- \
         data_ext0=nbw3 data_ext1=p2 data_ext2=p3 data_ext3=nbw6 \
         reg_L2=1e-4 step_size=0.25 top_dropout=0.5 \
         LessVerbose test_interval=25 evaluation_fn=$perf_fn \
         @param/seq2-bown-my.param > ${log_fn}
