erl -make all
START werl -name nameservice -setcookie bob
START werl -name koordinator -setcookie bob
START werl -name clients -setcookie bob
START werl -name zookeeper -setcookie bob