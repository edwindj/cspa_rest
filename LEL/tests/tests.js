
function tests(serviceurl, div) {

  test(div, "Check output of test job", function(handler) {
    var job = Job("test1", "/LEL")
      .input( "data"
      	    , serviceurl + "/tests/test1_data.csv"
      	    , serviceurl + "/tests/test1_data_schema.json"
      	    )
      .input( "rules"
      	    , serviceurl + "/tests/test1_rules.txt"
      	    );

    expect_equal()
    .on_error(handler)(job, "/LEL/tests/test1_ref.json");
  });

}

