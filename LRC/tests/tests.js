
function tests(serviceurl, div) {

  test(div, "Check output of test job", function(handler) {
    var job = Job("test1", "/LRC")
      .input("data", serviceurl + "/tests/test1_data.csv", 
        serviceurl + "/tests/test1_data_schema.json")
      .input("rules", serviceurl + "/tests/test1_rules.txt");
    expect_equal().on_error(handler)(job, "/LRC/tests/test1_ref.json");
  });

  test(div, "Incorrect column name in data schema", function(handler) {
    var job = Job("test2", "/LRC")
      .input("data", serviceurl + "/tests/test2_data.csv", 
        serviceurl + "/tests/test2_data_schema.json")
      .input("rules", serviceurl + "/tests/test2_rules.txt");
    expect_error().on_error(handler)(job);
  });

}

