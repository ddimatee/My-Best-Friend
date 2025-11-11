// JS sencillo para CRUD de Mascotas
(function(){
  const API = (localStorage.getItem('apiBase') || 'http://localhost:3000').replace(/\/$/, '');
  const el = (id) => document.getElementById(id);

  // Mostrar base del API
  const apiBaseEl = document.getElementById('apiBase');
  if (apiBaseEl) apiBaseEl.textContent = API;

  const statusEl = el('status');

  function parseEstiloVida(s) {
    return (s || '')
      .split(',')
      .map(x => x.trim())
      .filter(Boolean);
  }

  function formData() {
    const cumple = el('cumpleanos').value ? new Date(el('cumpleanos').value).toISOString() : undefined;
    return {
      userId: el('userId').value.trim() || undefined,
      nombre: el('nombre').value.trim(),
      imagenPath: el('imagenPath').value.trim() || undefined,
      cumpleanos: cumple,
      situacion: el('situacion').value || undefined,
      sexo: el('sexo').value || undefined,
      raza: el('raza').value.trim() || undefined,
      rol: el('rol').value || undefined,
      estiloVida: parseEstiloVida(el('estiloVida').value),
      seguimiento: el('seguimiento').checked,
      coCuidado: el('coCuidado').checked,
      oculto: el('oculto').checked
    };
  }

  function setForm(data = {}) {
    el('_id').value = data._id || '';
    el('userId').value = (data.userId && (data.userId.$oid || data.userId)) || '';
    el('nombre').value = data.nombre || '';
    el('imagenPath').value = data.imagenPath || '';
    el('cumpleanos').value = data.cumpleanos ? new Date(data.cumpleanos).toISOString().slice(0,10) : '';
    el('situacion').value = data.situacion || '';
    el('sexo').value = data.sexo || '';
    el('raza').value = data.raza || '';
    el('rol').value = data.rol || '';
    el('estiloVida').value = Array.isArray(data.estiloVida) ? data.estiloVida.join(', ') : '';
    el('seguimiento').checked = !!data.seguimiento;
    el('coCuidado').checked = !!data.coCuidado;
    el('oculto').checked = !!data.oculto;
  }

  function rowTemplate(m) {
    const fecha = m.fechaCreacion ? new Date(m.fechaCreacion).toLocaleString() : '-';
    const estilos = (m.estiloVida || []).map(x => `<span class="tag">${x}</span>`).join(' ');
    return `<tr>
      <td><strong>${m.nombre}</strong><div class="mono muted">${m._id}</div></td>
      <td><span class="mono">${m.userId}</span></td>
      <td>${m.raza || ''} ${m.sexo ? `• ${m.sexo}` : ''} ${m.situacion ? `• ${m.situacion}` : ''} ${estilos ? `• ${estilos}` : ''}</td>
      <td>${m.seguimiento ? 'Seguimiento' : ''} ${m.coCuidado ? '• Co-cuidado' : ''} ${m.oculto ? '• Oculto' : ''}</td>
      <td>${fecha}</td>
      <td>
        <button class="btn" data-action="edit" data-id="${m._id}">Editar</button>
        <button class="btn btn-danger" data-action="del" data-id="${m._id}">Borrar</button>
      </td>
    </tr>`;
  }

  async function list() {
    try {
      const filterInput = el('filterUserId');
      const userId = filterInput ? filterInput.value.trim() : '';
      const url = new URL(`${API}/api/mascotas`);
      if (userId) url.searchParams.set('userId', userId);
      const res = await fetch(url.toString());
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      if (!Array.isArray(data)) throw new Error('Respuesta inesperada');
      el('rows').innerHTML = data.map(rowTemplate).join('');
    } catch (e) {
      console.error('Error listando mascotas:', e);
      alert('No se pudieron cargar las mascotas.');
    }
  }

  async function save() {
    const id = (el('_id').value || '').trim();
    const body = formData();
    if (statusEl) statusEl.textContent = 'Guardando...';
    try {
      if (!body.userId) throw new Error('userId es requerido');
      if (!body.nombre) throw new Error('nombre es requerido');
      let res;
      if (id) {
        res = await fetch(`${API}/api/mascotas/${id}`, { method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
      } else {
        res = await fetch(`${API}/api/mascotas`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
      }
      const data = await res.json();
        if (!res.ok) {
          console.warn('Fallo SAVE mascota id=', id, 'status=', res.status, 'payload=', data);
          // Intento diagnóstico si existe id
          if (id) {
            try {
              const dbg = await fetch(`${API}/api/mascotas/debug/${id}`);
              const dbgData = await dbg.json();
              console.info('Diagnóstico debug mascota (save):', dbgData);
            } catch (e2) {
              console.warn('No se pudo obtener debug mascota:', e2);
            }
          }
          throw new Error(data.error || 'Error');
        }
      await list();
      setForm({});
    } catch (e) {
      alert(e.message);
    } finally {
      if (statusEl) statusEl.textContent = '';
    }
  }

  async function removeItem(id) {
    if (!confirm('¿Borrar mascota?')) return;
    const res = await fetch(`${API}/api/mascotas/${id}`, { method: 'DELETE' });
    const data = await res.json();
    if (!res.ok) return alert(data.error || 'Error');
    list();
  }

  document.addEventListener('click', async (e) => {
    const btn = e.target.closest('button');
    if (!btn) return;
    if (btn.id === 'saveBtn') return save();
    if (btn.id === 'clearBtn') return setForm({});
    if (btn.id === 'refreshBtn') return list();
    const action = btn.dataset.action;
    const id = btn.dataset.id;
    if (action === 'edit') {
      const res = await fetch(`${API}/api/mascotas/${id}`);
      const data = await res.json();
        if (!res.ok) {
          console.warn('Fallo GET mascota id=', id, 'status=', res.status, 'payload=', data);
          try {
            const dbg = await fetch(`${API}/api/mascotas/debug/${id}`);
            const dbgData = await dbg.json();
            console.info('Diagnóstico debug mascota (edit):', dbgData);
          } catch (e2) {
            console.warn('No se pudo obtener debug mascota:', e2);
          }
          return alert(data.error || 'No encontrado');
        }
      setForm(data);
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
    if (action === 'del') removeItem(id);
  });

  const filter = el('filterUserId');
  if (filter) filter.addEventListener('input', () => list());

  // Primera carga
  list();
})();
