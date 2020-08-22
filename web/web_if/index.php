<html>
<head>
  <meta charset="UTF-8">
  <html lang="en">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="<?php echo echo $_SERVER['REQUEST_SCHEME']."://$_SERVER['HTTP_HOST']?>/style/normalize.css">
  <link rel="stylesheet" href="<?php echo echo $_SERVER['REQUEST_SCHEME']."://$_SERVER['HTTP_HOST']?>/style/custom.css">
  <link href="https://fonts.googleapis.com/css?family=Montserrat&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>Services Status</title>
</head>
<body>
  <?php
    require_once("vars.php");
    $all = false;
    if (key_exists('PATH_INFO',$_SERVER)){
        $params = explode("/",substr($_SERVER['PATH_INFO'],1));
        if($params[0] == "all"){
	         $all = true;
         }
	  }
    $dsn = "mysql:host=localhost;port=3306;dbname=services_status;charset=utf8";
    $db = new PDO($dsn, DB_USER, DB_PASS);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $date = new DateTime();
    setlocale(LC_TIME, 'fra_fra');
    date_default_timezone_set('Europe/Paris');
    $currenttime = $date->getTimestamp();
    $warning_time = 150;
?>
  <div id="content">
    <h1 class='font-weight-bold'>Services status</h1>
    <?php
      //DB Init. & Query
      $stmt = $db->prepare("SELECT * FROM status");
      $stmt -> execute();
      $status = $stmt->fetchAll(PDO::FETCH_ASSOC);

      foreach($status as $dev){
        if ($all || !$all && $dev['public'] == 1){
          //Data Structures
          $status = array(
            'server' => '',
            'service' => '',
          );

          $data = array(
            'general' => array('iclass' => "",
                              'date' =>  0),
            'server' => array('iclass' => "",
                              'date' => 0),
            'service' => array('iclass' => "",
                              'date' => 0)
          );

          //Server Status Check
          if ($currenttime - $dev['lastseen'] >= 65){
            if ($currenttime - $dev['lastseen'] >= $warning_time){
              $status['server'] = 'off';
            } else {
              $status['server'] = 'unknown';
            }
          } else {
            $status['server'] = 'ok';
          }

          //Service Status Check
          if ($currenttime - $dev['servicelastseen'] >= 65){
            if ($currenttime - $dev['servicelastseen'] >= $warning_time){
              $status['service'] = 'off';
            } else {
              $status['service'] = 'unknown';
            }
          } else {
            $status['service'] = 'ok';
          }




          //Server Status Data
          if($status['server'] == 'ok') {
            $data['server']['iclass'] = "ok_device fa fa-check-circle";
            $data['server']['date'] = "Running";
          } elseif($status['server'] == 'unknown'){
            $data['server']['iclass'] = "unkn_device fa fa-question-circle";
            $data['server']['date'] = date("d/m H:i:s",intval($dev['lastseen']));
          } else {
            $data['server']['iclass'] = "err_device fa fa-exclamation-circle";
            $data['server']['date'] = date("d/m H:i:s",intval($dev['lastseen']));
          }

          //Service Status Data
          if($status['service'] == 'ok') {
            $data['service']['iclass'] = "ok_device fa fa-check-circle";
            $data['service']['date'] = "Running";
          } elseif($status['service'] == 'unknown'){
            $data['service']['iclass'] = "unkn_device fa fa-question-circle";
            $data['service']['date'] = date("d/m H:i:s",intval($dev['servicelastseen']));
          } else {
            $data['service']['iclass'] = "err_device fa fa-exclamation-circle";
            $data['service']['date'] = date("d/m H:i:s",intval($dev['servicelastseen']));
          }


          //General Status Data
          if ($status['server'] == 'ok' && $status['service'] == 'ok'){
            $data['general']['iclass'] = "ok_device fa fa-check-circle";
            $data['general']['date'] = "Running";
          } else if ($status['server'] == 'off' || $status['service'] == 'off'){
            $data['general']['iclass'] = "err_device fa fa-exclamation-circle";
            $data['general']['date'] = date("d/m H:i:s",intval($dev['servicelastseen']));
          } else {
            $data['general']['iclass'] = "unkn_device fa fa-question-circle";
            $data['general']['date'] = date("d/m H:i:s",intval($dev['servicelastseen']));
          }

          echo "<div class='device'>
                  <i class='main ".$data['general']['iclass']."'></i>
                  <p class='main name'>".$dev['name']."</p>
                  <p class='main date'>".$data['general']['date']."</p>
                  <div class='sub sub-container'>
                    <div class='sub server'>
                      <i class='".$data['server']['iclass']."'></i>
                      <p class='main name'>Server</p>
                      <p class='date'>".$data['server']['date']."</p>
                    </div>
                    <div class='sub service'>
                    <i class='".$data['service']['iclass']."'></i>
                      <p class='main name'>Service</p>
                      <p class='date'>".$data['service']['date']."</p>
                    </div>
                  </div>
                </div>";
        }
      }
  ?>
  </div>


  <div id="legends">
    <i class="err_device fa fa-exclamation-circle"></i> = Offline<br>
    <i class="unkn_device fa fa-question-circle"></i> = Degradation<br>
    <i class="ok_device fa fa-check-circle"></i> = Working<br>
  </div>

</body>
</html>
