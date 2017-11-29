from time import sleep


def click_and_wait(elem, t):
    elem.click()
    sleep(t)
    return elem


def get_closable_alerts(b):
    alerts = b.find_elements_by_class_name('alert')
    alerts = [alert for alert in alerts if alert.find_elements_by_class_name('fa-close')]
    return alerts


def check_and_close_msg(b, wait_time):
    """Check for presence of message and close."""
    alerts = get_closable_alerts(b)
    assert len(alerts) == 1
    alert = alerts[0]
    close_button = alert.find_elements_by_class_name('fa-close')
    click_and_wait(close_button[0], wait_time)
    alerts = get_closable_alerts(b)
    assert len(alerts) == 0


def assert_with_timeout(fn, max_t):
    t = 0
    while t <= max_t:
        try:
            fn()
            break
        except AssertionError as e:
            if t < max_t:
                sleep(1)
                t = t + 1
            else:
                raise (e)
