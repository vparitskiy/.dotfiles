__get_models = None

try:
    from django.apps import apps
except ImportError:
    try:
        from django.db.models.loading import get_models as __get_models
    except ImportError:
        pass
else:
    __get_models = apps.get_models

if __get_models:
    try:
        for m in __get_models():
            globals()[m.__name__] = m

            if hasattr(m, '_meta') and (m._meta, 'app_label'):
                globals()['{}_{}'.format(m._meta.app_label, m.__name__)] = m

    except Exception:
        pass

__urlresolvers = None

try:
    from django import urls as __urlresolvers
except ImportError:
    try:
        from django.core import urlresolvers as __urlresolvers
    except Exception:
        pass

if __urlresolvers:
    globals()['reverse'] = __urlresolvers.reverse
    globals()['resolve'] = __urlresolvers.resolve

try:
    from django.db.models import Q, Prefetch, Count, Min, Max
except ImportError:
    pass
else:
    globals()['Q'] = Q
    globals()['Prefetch'] = Prefetch
    globals()['Count'] = Count
    globals()['Min'] = Count
    globals()['Max'] = Count
