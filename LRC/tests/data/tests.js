
function tests(div) {

  test(div, "Check output of test job", function(handler) {
    var job = Job("test1", "/LRC")
      .input("data", "http://127.0.0.1:8080/LRC/tests/data.csv", 
        "http://127.0.0.1:8080/LRC/tests/data_schema.json")
      .input("rules", "http://127.0.0.1:8080/LRC/tests/rules.txt");
    expect_equal().on_error(handler)(job, "/LRC/tests/ref.json");
  });

  test(div, "Incorrect column name in data schema", function(handler) {
    var job = Job("test2", "/LRC")
      .input("data", "http://127.0.0.1:8080/LRC/tests/test2_data.csv", 
        "http://127.0.0.1:8080/LRC/tests/test2_data_schema.json")
      .input("rules", "http://127.0.0.1:8080/LRC/tests/test2_rules.txt");
    expect_error().on_error(handler)(job);
  });

}

